#customer-service/tcl/cs-view-procs.tcl
ad_library {

    views for customer-service
    @creation-date 21 Jan 2017
    @Copyright (c) 2017 Benjamin Brink
    @license GNU General Public License 2
    @project home: http://github.com/tekbasse/customer-service
    @address: po box 20, Marylhurst, OR 97036-0020 usa
    @email: tekbasse@yahoo.com
    
}


ad_proc -private cs_customer_reps_of_cat {
    args
} {
    Returns user_ids of arg: contact_id that are associate with category as a list.
    <br/>
    customer_id is customer's contact_id from qal_contacts.
    <br/>
    <code>args</code> can be passed as name value list. Minimum required is contact_id and a category reference:
    <br>
    Accepted cs_categories.names are: <code>category_id</code>, <code>parent_id</code>, and <code>label</code>.
    <br>
    If there is an error, an empty list is returned.
} {
    upvar 1 instance_id instance_id
    # cs_customer_reps_of_cat and cs_support_reps_of_cat are separate, because
    # this is a place where one or the other may be modified,
    # and modification becomes more difficult if these use a single call point.

    set assigned_uids_list [list ]
    qf_nv_list_to_vars $args [list category_id parent_id label contact_id]

    # if category_id not avail, try parent_id as cateogry_id
    # if that is not avail, try label.
    if { ![qf_is_natural_number $category_id] } {
        if { [qf_is_natural_number $parent_id ] } {
            set cat_id $parent_id
        } elseif { $label ne "" } {
            set cat_id [cs_cat_id_of_label $label]
        }
    } else {
        set cat_id $category_id
    }
    if { $cat_id ne "" } {
        set property_label [cs_cat_cc_property_label $cat_id]
    
        if { $property_label ne "" } {
            # convert to property_id
            set property_id [qc_property_id $property_label $instance_id]
        
            if { $property_id ne "" } {
                set role_ids_list [qc_roles_of_prop_priv $property_id $privilege]
        
                if { [llength $role_ids_list] > 0 } {
                    # get user_ids limited by hf_role_id in one query
                    set user_ids_list [qc_user_ids_of_contact_id $contact_id $role_ids_list]
                }
            }
        }
        # add user_ids from cs_cat_assignment_map
        set assigned_uids_list [db_list ]
    } else {
        ns_log Notice "cs_customer_reps_of_cat: category_id not found. category_id '${category_id} parent_id '${parent_id}' category label '${label}'"
    }
}
    return $assigned_uids_list
}


ad_proc -private cs_support_reps_of_cat {
    args
} {
    Returns user_ids of arg: contact_id that are associate with category as a list.
    <br/>
    If arg: <code>type</code> is customer_id is customer's contact_id from qal_contacts.
    <br/>
    If arg: <code>type</code> is 'support' reps, contact_id is instance_id from qc_set_instance_id
    <br/>
    <code>args</code> can be passed as name value list or left empty for all cases.
    <br>
    Accepted cs_categories.names are: <code>category_id</code>, <code>parent_id</code>, and <code>label</code>.
    <br>
    If there is an error, an empty list is returned.
} {
    upvar 1 instance_id instance_id
    set assigned_uids_list [list ]
    qf_nv_list_to_vars $args [list category_id parent_id label contact_id type]
    set types_list [list customer support]
    if { $type in $types_list } {
        # read cs_categories.property_label
        # convert to property_id
        set property_id [qc_property_id $property_label $instance_id]
        
        if { $property_id ne "" } {
            set role_ids_list [qc_roles_of_prop_priv $property_id $privilege]
            
        } 
        
        if { [llength $role_ids_list] > 0 } {
            # get user_ids limited by hf_role_id in one query
            set user_ids_list [qc_user_ids_of_contact_id $contact_id $role_ids_list]
        }
        # add user_ids from cs_cat_assignment_map
        # if category_id not avail, try parent_id as cateogry_id
        # if that is not avail, try label.
        if { $category_id eq "" } {
            if { $parent_id ne "" } {
                set category_id $parent_id
            } elseif { $label ne "" } {
                
                ##code
            }
        }
        set assigned_uids_list [db_list ]
    } else {
        ns_log Notice "cs_reps_of_cat: type '${type}' not valid. Must be 'customer' or 'support'"
    }
    return $assigned_uids_list
}


ad_proc -private cs_cat_cs_property_label {
    category_id
} {
    Returns property_label associated with a category for customer support reps, or empty string if not available.
} {
    upvar 1 instance_id instance_id
    set cs_property_label ""
    db_0or1row cs_categories_r_cspl {select cs_property_label from cs_categories 
        where id=:category_id
        and instance_id=:instance_id
        and active_p!='0'
    }
    return $cs_property_label
}

ad_proc -private cs_cat_cc_property_label {
    category_id
} {
    Returns property_label associated with a category for customer reps.
} {
    upvar 1 instance_id instance_id
    set cc_property_label ""
    db_0or1row cs_categories_r_cspl {select cc_property_label from cs_categories 
        where id=:category_id
        and instance_id=:instance_id
        and active_p!='0'
    }
    return $cc_property_label
}

ad_proc -private cs_tickets_assigned_to {
    {user_id ""}
} {
    Lists ticket_ids for a customer support user_id as a list.
} {
    upvar 1 instance_id instance_id
    # cs_tickets
    set id_list [db_list cs_support_rep_ticket_map {select ticket_id from cs_support_rep_ticket_map
        where user_id=:user_id
        and instance_id=:instance_id} ]
    return $id_list
}

ad_proc -private cs_tickets_subscribed_to {
    {user_id ""}
} {
    Lists ticket_ids for a customer rep user_id as a list.
} {
    upvar 1 instance_id instance_id
    # cs_tickets
    set id_list [db_list cs_customer_rep_ticket_map {select ticket_id from cs_customer_rep_ticket_map
        where user_id=:user_id
        and instance_id=:instance_id} ]
    return $id_list
}

ad_proc -private cs_est_customer_response_time {
} {
    Returns anticipated customer response time as a cobbler list, fixed system time vs. historical probability
} {
    upvar 1 instance_id instance_id
    # cs_anticipated_customer_response_time
    ##code


}

# The following will be called in lib as includes, but
# also maybe in cron monitoring procs, which is why these are procs:

ad_proc -private cs_stats_ticket_response {
} {
    Returns estimated time for ticket response (for nonscheduled events).
} {
    upvar 1 instance_id instance_id
    # cs_stats_til_ticket_response (only for nonscheduled events)
    ##code
}

ad_proc -private cs_stats_ticket_close {
} {
    Returns estimated time for ticket resolution (for nonscheduled events).
} {
    upvar 1 instance_id instance_id
    # cs_stats_til_ticket_close (only for nonscheduled_events)
    ##code

}
