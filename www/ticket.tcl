set title "Ticket'"
set context [list [list index "Documentation"] $title]

#this is the page for displaying a single ticket
#and adding a message to it, or changing subscription(s)

# if a message was posted after this was retrieved, but before posting
# provide an option to edit post before posting.

## code   This comment gets moved to adp/tcl page:
# if !$tickets.unscheduled_service_req_p
#  ask customer when is preferred service time (in the first created message).
#  in case of service interruptions are needed.
#  and ask when is most important that interruptions are minimized.
