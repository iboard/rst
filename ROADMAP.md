Ruby Shell Tools - Road-map
===========================

Review args for calendar
------------------------

**What will be the best behavior to use it from the command-line?**
  
        rst cal -e "Some Text"  .... should create an entry for today
        rst cal -e 1w .............. should create an entry for today+1week
        rst cal -e mon ............. should create an entry for next Monday
        rst cal -e when ............ without text should open $editor (as git commit)
                        ............ should -e be a default? (may be
                                     tricky to parse
        rst cal -w [n]  ............ should list the current +n week(s)
        
**Ideas for new feature 'Notes'**

        rst note ................... should open $editor to save a note
                                     first line of note should be the subject.
        rst note --subject 'subject'
        rst note --subject '..' FILE
        rst note FILE .............. subject from the first line of FILE
        rst note -- ................ should read from $stdin
        rst note --list ............ should list with store-ids
        rst note --delete ID ....... should delete note with store-id ID
        rst note --id ID --email EMAIL should send the note as email
        rst note --id ID --edit .... should open note in $editor

        