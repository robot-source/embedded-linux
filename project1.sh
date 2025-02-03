#!/bin/bash 

# function to display scheduled tasks


list_tasks() {
	echo "Scheduled Tasks:"
	crontab -l
	echo
}


add_task() {
	read -p "Enter the Command OR Script to be excuted: " command
	read -p "Enter the schedule (hourly, daily, weekly, minutely): " schedule
	read -p "Enter any additional parameters: " parameters
	read -p "Enter the log file path (e.g., /path/to/logfile.log): " logfile
	read -p "Do you want to run this command immediately? (y/n): " run_now

if ! command -v $command &>/dev/null && [ ! -f "$command" ]; then
        echo "Error: Command or script does not exist."
        return
fi

case $schedule in
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
	echo "Invalid Schedule. Please choose hourly, daily, or weekly."
	return
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

}

#Function to remove task

remove_task() {
	read -p "Enter the command or script be removed: " command

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
}

# Main menu loop

while true; do
	echo "Task Scheduler"
	echo "1. List Scheduled tasks"
	echo "2. Add a task"
	echo "3. Remove a task"
	echo "4. Exit"
	read -p "Enter your choice: " choice
	echo

	case $choice in
	  1)
		list_tasks
		;;
	  2)
		add_task
		;;
	  3)
		remove_task
		;;
	  4)
		break
		;;
	  *)
		echo "Invalid choice. Please try again."
		echo
		;;
	esac
done


