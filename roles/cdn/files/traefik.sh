traefik="/home/cdn/traefik --providers.file.filename=traefik.yml"
traefik_session="traefik-session"

if tmux new-session -d -s $traefik_session; then
    echo "Created authserver session: $traefik_session"
else
    echo "Error when trying to create authserver session: $traefik_session"
fi

if tmux send-keys -t $traefik_session "$traefik" C-m; then
    echo "Executed \"traefik\" inside $traefik_session"
    echo "You can attach to $traefik_session and check the result using \"tmux attach -t $traefik_session\""
else
    echo "Error when executing \"$traefik\" inside $traefik_session"
fi