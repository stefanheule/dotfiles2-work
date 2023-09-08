# Example: tb_download_dir /prod/resourceinsights-backend/cost-graph ri
# Usage: tb_download_dir <remote_path> <local_path>
function tb_download_dir() {
  local remote_dir="$1"
  local local_dir=$2
 
  local list="$(tb-cli ls "$remote_dir" -l --json)"
  for file in $(jq '.result[]' -c <<< "$list"); do
    local file_type="$(jq '.type' -r <<< "$file")"
    local remote_path="${remote_dir}/$(jq '.name' -r <<< "$file")"
    local local_path="${local_dir}/$(jq '.name' -r <<< "$file")"

    #echo "remote: $remote_path -> $local_path [file=$file]"
  
    if [ "$file_type" = "dir" ]; then
      mkdir -p "$local_path"
      tb_download_dir "$remote_path" "$local_path"
    elif [ "$file_type" = "blob" ]; then
        echo "downloading file: $remote_path to $local_path"
          tb-cli get "$remote_path" "$local_path"
    fi
  done
}
