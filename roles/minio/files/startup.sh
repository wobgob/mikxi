minio="/bin/bash /home/minio/minio.sh"
minio_session="minio-session"

if tmux new-session -d -s $minio_session; then
    echo "Created authserver session: $minio_session"
else
    echo "Error when trying to create authserver session: $minio_session"
fi

if tmux send-keys -t $minio_session "$minio" C-m; then
    echo "Executed \"minio\" inside $minio_session"
    echo "You can attach to $minio_session and check the result using \"tmux attach -t $minio_session\""
else
    echo "Error when executing \"$minio\" inside $minio_session"
fi