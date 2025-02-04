#!/bin/bash 

# function to display scheduled tasks


list_tasks() {
	echo "Scheduled Tasks:"
	crontab -l
	echo
}

schedule_notification() {
    read -p "Enter the notification message (e.g., 'Go have a break'): " message
    read -p "How often do you want the notification? (hourly/daily/custom): " frequency

    case "$frequency" in
        hourly)
            cron_schedule="0 * * * *"  # Every hour
            ;;
        daily)
            cron_schedule="0 9 * * *"  # Every day at 9 AM (customizable)
            ;;
        custom)
            read -p "Enter your custom cron expression (e.g., '*/10 * * * *' for every 10 minutes): " cron_schedule
            ;;
        *)
            echo "Invalid frequency. Please choose hourly, daily, or custom."
            return
            ;;
    esac

    
    notification_command="DISPLAY=:0 /usr/bin/notify-send '$message'"

    # Add the task to crontab
    (
	crontab -l 2>/dev/null
    echo "$cron_schedule $notification_command" 
	) | crontab -

    echo "Notification scheduled successfully."
    echo "Task: '$message' will appear at the chosen frequency."
}


add_task() {
	read -p "Enter the Command OR Script to be excuted: " command
	read -p "Do you want to execute this Command OR Script only once or repeatedly? (once/repeat): " choice
	read -p "Enter the log file path (e.g., /path/to/logfile.log): " logfile
	read -p "Do you want to run this command immediately? (y/n): " run_now

if ! command -v $command   &>/dev/null && [ ! -f "$command" ]; then
        echo "Error: Command or script does not exist."
        return
fi

if [[ "$choice" == "once" ]]; then
        read -p "Enter the execution time (e.g., 'now + 5 minutes', 'tomorrow 5pm', '2024-02-10 14:30'): " exec_time
		echo "$command >> $logfile 2>&1" | at "$exec_time"
        echo "One-time task scheduled for: $exec_time"
    elif [[ "$choice" == "repeat" ]]; then
        read -p "Enter the schedule (minutely, hourly, daily, weekly, or custom cron expression): " schedule
        read -p "Enter any additional parameters: " parameters

        case "$schedule" in
            minutely) 
			cron_schedule="* * * * *" 
			;;
            hourly)
			cron_schedule="0 * * * *" 
			;;
            daily)
			cron_schedule="0 0 * * *" 
			;;
            weekly)
			cron_schedule="0 0 * * 0" 
			;;
            *)
                if [[ "$schedule" =~ ^([0-9\*/,-]+\s){4}[0-9\*/,-]+$ ]]; then
                    cron_schedule="$schedule"
                else
                    echo "Invalid schedule. Please enter a valid cron expression or choose minutely, hourly, daily, or weekly."
                    return
                fi
                ;;
        esac



#Add the task to the crontab
(
	crontab -l 2> ~/Desktop/error.txt ;
    echo "$cron_schedule $command $parameters >> $logfile 2>&1"
) | crontab -

	echo "Task scheduled successfully."
	echo
 if [[ "$run_now" =~ ^[Yy]$ ]]; then
        echo "Running the command immediately..."
        $command $parameters
    fi
fi
}

#Function to remove task

remove_task() {

	read -p "Do you want to remove all tasks in your schedule? (y/n): " all
    if [[ "$all" =~ ^[Yy]$ ]]; then
        read -p "Are you sure you want to remove all scheduled tasks? This will delete everything! (y/n): " confirm_all
        if [[ "$confirm_all" =~ ^[Yy]$ ]]; then
            crontab -r
            echo "All tasks removed successfully."
        else
            echo "Operation canceled."
        fi
    else	
		read -p "Enter the command or script to be removed: " command

		if [ -z "$command" ]; then
        echo "Error: Command cannot be empty."
        return
    	fi

		echo "Current scheduled tasks:"
    	crontab -l | grep "$command"
    	read -p "Are you sure you want to remove these tasks? (y/n): " confirm
    	if [[ "$confirm" =~ ^[Yy]$ ]]; then
        crontab -l | grep -v "$command" | crontab -
        echo "Task removed successfully."
    	else
        echo "Operation canceled."
    	fi
    echo
	fi
}

# Main menu loop

while true; do
	echo "Task Scheduler"
	echo "1. List Scheduled tasks"
	echo "2. Notification"
	echo "3. Add a task"
	echo "4. Remove a task"
	echo "5. Exit"
	read -p "Enter your choice: " choice
	echo

	case $choice in
	  1)
		list_tasks
		;;
		
	  2)
	  	schedule_notification
		;;
	  3)
		add_task
		;;
	  4)
		remove_task
		;;
	  5)
		break
		;;
	  *)
		echo "Invalid choice. Please try again."
		echo
	esac
done


