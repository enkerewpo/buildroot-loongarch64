#!/bin/sh
# ┌──────────────────────────────────────────────────────────────────┐
# │  pivot.sh — chroot into a persistent rootfs from initramfs      │
# │  Usage: pivot.sh [ID]                                           │
# │    No args  → list partitions and exit                          │
# │    ID       → chroot to partition #ID                           │
# │    exit     → type 'exit' to return to initramfs                │
# └──────────────────────────────────────────────────────────────────┘

set -u

RST='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'

MNT="/mnt/rootfs"

# ── Discover block devices ───────────────────────────────────────────
discover_partitions() {
    idx=0
    for dev in /sys/class/block/*; do
        name=$(basename "$dev")
        case "$name" in loop*|ram*|dm-*|zram*) continue ;; esac
        devpath="/dev/$name"
        [ -b "$devpath" ] || continue

        sectors=$(cat "$dev/size" 2>/dev/null || echo 0)
        size_mb=$((sectors * 512 / 1024 / 1024))
        if [ "$size_mb" -ge 1024 ]; then
            size_hr="$(awk "BEGIN{printf \"%.1fG\", $size_mb/1024}")"
        else
            size_hr="${size_mb}M"
        fi

        ptype="disk"; [ -f "$dev/partition" ] && ptype="part"
        fs=$(blkid -o value -s TYPE "$devpath" 2>/dev/null || echo "—")
        label=$(blkid -o value -s LABEL "$devpath" 2>/dev/null || echo "")
        mountpoint=$(awk -v d="$devpath" '$1==d {print $2}' /proc/mounts 2>/dev/null | head -1)
        if [ -n "$mountpoint" ]; then
            mount_info="${GREEN}mounted @ ${mountpoint}${RST}"
        else
            mount_info="${DIM}not mounted${RST}"
        fi

        idx=$((idx + 1))
        eval "PART_${idx}_DEV=\"$devpath\""
        eval "PART_${idx}_NAME=\"$name\""
        eval "PART_${idx}_SIZE=\"$size_hr\""
        eval "PART_${idx}_TYPE=\"$ptype\""
        eval "PART_${idx}_FS=\"$fs\""
        eval "PART_${idx}_LABEL=\"$label\""
        eval "PART_${idx}_MOUNT=\"$mountpoint\""
        eval "PART_${idx}_MOUNT_INFO=\"$mount_info\""
    done
    PART_COUNT=$idx
}

# ── Print partition table ────────────────────────────────────────────
print_partitions() {
    printf "\n"
    printf "  ${CYAN}${BOLD}block devices${RST}\n"
    printf "  ${DIM}──────────────────────────────────────────────────${RST}\n"
    printf "  ${DIM}%-4s %-12s %-6s %-5s %-8s %-10s %s${RST}\n" \
        "ID" "DEVICE" "SIZE" "TYPE" "FS" "LABEL" "STATUS"
    printf "  ${DIM}──────────────────────────────────────────────────${RST}\n"

    i=1
    while [ $i -le "$PART_COUNT" ]; do
        eval "name=\$PART_${i}_NAME"
        eval "size=\$PART_${i}_SIZE"
        eval "ptype=\$PART_${i}_TYPE"
        eval "fs=\$PART_${i}_FS"
        eval "label=\$PART_${i}_LABEL"
        eval "mount_info=\$PART_${i}_MOUNT_INFO"

        if [ "$ptype" = "disk" ]; then
            printf "  ${DIM}%-4s${RST} ${WHITE}%-12s${RST} %-6s ${DIM}%-5s${RST} %-8s %-10s %b\n" \
                "—" "$name" "$size" "$ptype" "$fs" "$label" "$mount_info"
        else
            printf "  ${YELLOW}%-4s${RST} ${WHITE}%-12s${RST} %-6s %-5s %-8s %-10s %b\n" \
                "$i" "$name" "$size" "$ptype" "$fs" "$label" "$mount_info"
        fi
        i=$((i + 1))
    done
    printf "  ${DIM}──────────────────────────────────────────────────${RST}\n"
    printf "\n"
}

# ── Chroot into persistent rootfs ────────────────────────────────────
do_chroot() {
    target_id="$1"

    if [ "$target_id" -lt 1 ] || [ "$target_id" -gt "$PART_COUNT" ] 2>/dev/null; then
        printf "  ${RED}error:${RST} invalid ID %s (valid: 1-%s)\n" "$target_id" "$PART_COUNT"
        return 1
    fi

    eval "target_dev=\$PART_${target_id}_DEV"
    eval "target_name=\$PART_${target_id}_NAME"
    eval "target_fs=\$PART_${target_id}_FS"
    eval "target_mount=\$PART_${target_id}_MOUNT"
    eval "target_label=\$PART_${target_id}_LABEL"

    printf "  ${CYAN}chroot${RST} → ${WHITE}%s${RST}" "$target_dev"
    [ -n "$target_label" ] && printf " (%s)" "$target_label"
    printf "\n\n"

    if [ "$target_fs" = "—" ] || [ -z "$target_fs" ]; then
        printf "  ${RED}error:${RST} no filesystem on %s\n" "$target_dev"
        printf "  ${DIM}hint: mkfs.ext4 -L ROOTFS %s${RST}\n" "$target_dev"
        return 1
    fi

    # Mount if not already mounted
    if [ -z "$target_mount" ]; then
        mkdir -p "$MNT"
        printf "  ${DIM}mount %s → %s${RST}\n" "$target_dev" "$MNT"
        if ! mount -t "$target_fs" "$target_dev" "$MNT"; then
            printf "  ${RED}error:${RST} mount failed\n"
            return 1
        fi
        target_mount="$MNT"
    else
        printf "  ${DIM}already mounted at %s${RST}\n" "$target_mount"
    fi

    # Sanity check
    if [ ! -d "$target_mount/bin" ] && [ ! -d "$target_mount/usr" ]; then
        printf "  ${YELLOW}warning:${RST} %s doesn't look like a rootfs (no /bin or /usr)\n" "$target_dev"
        printf "  continue? [y/N] "
        read -r ans
        case "$ans" in y|Y) ;; *) return 1 ;; esac
    fi

    # Mount virtual filesystems inside chroot target
    printf "  ${DIM}mounting /dev /proc /sys /dev/pts${RST}\n"
    mkdir -p "$target_mount/dev" "$target_mount/proc" "$target_mount/sys" "$target_mount/dev/pts" "$target_mount/tmp"
    mountpoint -q "$target_mount/dev"     || mount -t devtmpfs devtmpfs "$target_mount/dev"
    mountpoint -q "$target_mount/proc"    || mount -t proc proc "$target_mount/proc"
    mountpoint -q "$target_mount/sys"     || mount -t sysfs sysfs "$target_mount/sys"
    mountpoint -q "$target_mount/dev/pts" || mount -t devpts devpts "$target_mount/dev/pts"

    # Make initramfs accessible inside chroot
    mkdir -p "$target_mount/initramfs"
    mount --bind / "$target_mount/initramfs" 2>/dev/null || true

    printf "\n"
    printf "  ${GREEN}${BOLD}entering persistent rootfs${RST}\n"
    printf "  ${DIM}type 'exit' to return to initramfs${RST}\n"
    printf "  ${DIM}initramfs available at /initramfs/${RST}\n"
    printf "\n"

    # Chroot with a proper shell
    if [ -x "$target_mount/bin/bash" ]; then
        chroot "$target_mount" /bin/bash -l
    elif [ -x "$target_mount/bin/ash" ]; then
        chroot "$target_mount" /bin/ash -l
    else
        chroot "$target_mount" /bin/sh -l
    fi

    # ── Cleanup after exit from chroot ───────────────────
    printf "\n  ${CYAN}returned to initramfs${RST}\n"
    printf "  ${DIM}cleaning up mounts...${RST}\n"

    umount "$target_mount/initramfs" 2>/dev/null || true
    umount "$target_mount/dev/pts" 2>/dev/null || true
    umount "$target_mount/dev" 2>/dev/null || true
    umount "$target_mount/proc" 2>/dev/null || true
    umount "$target_mount/sys" 2>/dev/null || true

    # Only unmount the rootfs if we mounted it
    if [ "$target_mount" = "$MNT" ]; then
        umount "$MNT" 2>/dev/null || umount -l "$MNT" 2>/dev/null || true
    fi

    printf "  ${GREEN}✓${RST} back in initramfs\n\n"
}

# ── Main ─────────────────────────────────────────────────────────────
discover_partitions

if [ $# -eq 0 ]; then
    print_partitions
    printf "  ${DIM}usage: pivot.sh <ID>  — chroot to partition #ID${RST}\n"
    printf "  ${DIM}       type 'exit' inside to return to initramfs${RST}\n\n"
    exit 0
fi

print_partitions
do_chroot "$1"
