#!/bin/bash
set -e

# Output directory for encoded MP4s. Override with: ARTIFACT_DIR=/path/to/dir bash process_all_videos.sh
ARTIFACT_DIR="${ARTIFACT_DIR:-$(pwd)/artifacts}"
mkdir -p "$ARTIFACT_DIR"

# Array of video and data pairs
declare -a pairs=(
  "collision_1.mp4 collision_1.txt"
  "collision_2.mp4 collision_2.txt"
  "max_speed_60.mp4 max_speed_60.txt"
  "lane_departure_warning_1.mp4 LDW_1.txt"
  "sl_60_collision.mp4 sl_60_collision.txt"
  "over_speed.mp4 over_speed.txt"
)

cd "$(dirname "$0")"

for pair in "${pairs[@]}"; do
  video=$(echo "$pair" | awk '{print $1}')
  data=$(echo "$pair" | awk '{print $2}')
  output_mp4="${video%.mp4}_output.mp4"
  
  echo "Processing $video..."
  
  rm -f direct_output.avi
  
  # Run simulation for 10 seconds
  QT_QPA_PLATFORM=offscreen timeout 10 ./build/bin/OpenADAS \
    --input_source=simulation \
    --input_video_path=data/videos/"$video" \
    --input_data_path=data/sim_data/"$data" \
    --on_dev_machine=true || true
    
  if [ -f direct_output.avi ]; then
    echo "Encoding $output_mp4..."
    ffmpeg -y -hide_banner -loglevel error -i direct_output.avi -vcodec libx264 -crf 23 "$ARTIFACT_DIR/$output_mp4"
  else
    echo "Failed to generate video for $video"
  fi
done

echo "Done processing all videos!"
