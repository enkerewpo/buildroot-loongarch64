# if the lines in nohup.out have changed, print the new lines to stdout

current_lines_count=0

while true; do
    new_lines_count=$(wc -l < nohup.out)
    # echo "new_lines_count: $new_lines_count"
    if [ $new_lines_count -gt $current_lines_count ]; then
        tail -n $(($new_lines_count - $current_lines_count)) nohup.out
        current_lines_count=$new_lines_count
    fi
done