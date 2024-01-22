#!/bin/bash

USER_ID=${1:-1000}
GROUP_ID=${2:-1000}
USERNAME=notifi-dev
USER_HOME_DIR="/home/${USERNAME}"

# Function to safely move a user/group to a new ID
move_to_new_id() {
    local type=$1  # 'user' or 'group'
    local name=$2  # original name
    local new_id=$3  # new id to assign
    local temp_name="$name"_old  # temporary name

    if [ "$type" == "user" ]; then
        usermod -l $temp_name $name  # rename user to temporary name
        usermod -u $new_id $temp_name  # change UID to new ID
        usermod -l $name $temp_name  # rename user back to original name
        # Change ownership of files in the user's home directory
        find $USER_HOME_DIR -user $new_id -exec chown -h $new_id {} \;
    elif [ "$type" == "group" ]; then
        groupmod -n $temp_name $name  # rename group to temporary name
        groupmod -g $new_id $temp_name  # change GID to new ID
        groupmod -n $name $temp_name  # rename group back to original name
    fi
}

# Check if the group with GROUP_ID already exists
if getent group $GROUP_ID ; then
    EXISTING_GROUP=$(getent group $GROUP_ID | cut -d: -f1)
    if [ "$EXISTING_GROUP" != "$USERNAME" ]; then
        move_to_new_id group $EXISTING_GROUP 9999  # Move existing group to a new GID
    fi
else
    addgroup --gid $GROUP_ID $USERNAME
fi

# Check if the user with USER_ID already exists
if getent passwd $USER_ID ; then
    EXISTING_USER=$(getent passwd $USER_ID | cut -d: -f1)
    if [ "$EXISTING_USER" != "$USERNAME" ]; then
        move_to_new_id user $EXISTING_USER 9999  # Move existing user to a new UID
    fi
else
    adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID $USERNAME
fi

# Ensure 'notifi-dev' group and user exist
getent group $GROUP_ID || addgroup --gid $GROUP_ID $USERNAME
getent passwd $USER_ID || adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID $USERNAME

# Additional setup (like setting 'notifi-dev' to sudoers) goes here
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME
chmod 0440 /etc/sudoers.d/$USERNAME

# Change ownership of files in the notifi-dev user's home directory
find $USER_HOME_DIR -user $USER_ID -exec chown -h $USER_ID:$GROUP_ID {} \;
