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

ad_proc -private cs_support_reps_of_cat {
    contact_id args
} {
    Returns user_ids associated with a category as a tcl_list
    <br/>
    <code>args</code> can be passed as name value list or left empty for all cases.
    <br>
    Accepted names are: <code>category_id</code>, <code>parent_id</code>, and <code>label</code>.
    <br>
} {
    # read cs_categories.property_label as property_id
    set property_id_exists_p [qc_property_id_exists_p $property_id $instance_id]
    if { $property_id_exists_p } {
                # property_id_exists_p should be true. It is looked up in a table.
                
        set role_ids_list [qc_roles_of_prop_priv $property_id $privilege]

    } 

    if { [llength $role_ids_list] > 0 } {
        
            # get user_ids limited by hf_role_id in one query
        set user_ids_list [qc_user_ids_of_contact_id $contact_id $role_ids_list]
    }
    # add user_ids from cs_cat_assignment_map
}

ad_proc -private cs_customer_reps_of_cat {
    customer_id args
} {
    Returns user_ids of customer that are associate with category as a list.
    <br/>
    <code>args</code> can be passed as name value list or left empty for all cases.
    <br>
    Accepted names are: <code>category_id</code>, <code>parent_id</code>, and <code>label</code>.
    <br>
} {
    # read cs_categories.property_label as property_id
    
    set property_id_exists_p [qc_property_id_exists_p $property_id $instance_id]
    if { $property_id_exists_p } {
                # property_id_exists_p should be true. It is looked up in a table.
                
        set role_ids_list [qc_roles_of_prop_priv $property_id $privilege]

    } 

    if { [llength $role_ids_list] > 0 } {
        
            # get user_ids limited by hf_role_id in one query
        set user_ids_list [qc_user_ids_of_contact_id $customer_id $role_ids_list]
    }
    # add user_ids from cs_cat_assignment_map

}



ad_proc -private cs_cat_role_map_read {
    args
} {
    Returns one roles associated with a category as a tcl list of lists.
    
    <br/>
    <code>args</code> can be passed as name value list or left empty for all cases.
    <br>
    Accepted names are: <code>category_id</code>, <code>parent_id</code>, and <code>label</code>.
    <br>
} {

}

# cs_tickets

# cs_stats_til_ticket_response (only for nonscheduled events)

# cs_stats_til_ticket_close (only for nonscheduled_events)

# cs_anticipated_customer_response_time