# .bash_profile

# Define cleanup function for SSH agent
# stops WSL 2 from failing to terminate
# due to SSH agent still running
function cleanup_ssh_agent() {
    # Check if ssh-agent is running before attempting to kill it
    if [ -n "$SSH_AGENT_PID" ]; then
        ssh-agent -k > /dev/null 2>&1
        unset SSH_AGENT_PID
        unset SSH_AUTH_SOCK
    fi
}

# Register the cleanup function to execute when the shell exits
trap cleanup_ssh_agent EXIT

# Your existing SSH agent initialization code
# check if an SSH agent is running
ssh-add -l &>/dev/null
# exit code 2 means no agent is running at all
if [ "$?" == 2 ]; then
    # Could not open a connection to your authentication agent.

    # Load stored agent connection info.
    test -r ~/.ssh-agent && \
        eval "$(<~/.ssh-agent)" >/dev/null

    ssh-add -l &>/dev/null
    if [ "$?" == 2 ]; then
        # Start agent and store agent connection info.
        (umask 066; ssh-agent > ~/.ssh-agent)
        eval "$(<~/.ssh-agent)" >/dev/null
    fi
fi

# Load identities
ssh-add -l &>/dev/null
if [ "$?" == 1 ]; then
    # The agent has no identities.
    # Time to add one.
    ssh-add -t 4h
fi

# Get the aliases and functions
[ -f $HOME/.bashrc ] && . $HOME/.bashrc

. "$HOME/.local/bin/env"