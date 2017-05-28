#
# Committers on the PPMC
#

class PPMCCommitters < React
  def render
    if @@ppmc.committers.all? {|id| @@ppmc.owners.include? id}
      _p 'All committers are members of the PPMC'
    else
      _h2.committers! 'Committers'
      _table.table.table_hover do
        _thead do
          _tr do
            _th 'id'
            _th 'public name'
          end
        end

        _tbody do
          @committers.each do |person|
            next if @@ppmc.owners.include? person.id
            _PPMCCommitter auth: @@auth, person: person, ppmc: @@ppmc
          end

          if @@auth
            _tr onDoubleClick: self.select do
              _td((@state == :open ? '' : "\u2795"), colspan: 3)
            end
          end
        end
      end

      if @state == :open
        _div.search_box do
          _CommitterSearch add: self.add
        end
      end
    end
  end

  # update props on initial load
  def componentWillMount()
    self.componentWillReceiveProps()
  end

  # compute list of committers
  def componentWillReceiveProps()
    committers = []
    
    @@ppmc.committers.each do |id|
      person = @@ppmc.roster[id]
      person.id = id
      committers << person
    end

    @committers = committers.sort_by {|person| person.name}
  end

  # open search box
  def select()
    return unless @@auth
    window.getSelection().removeAllRanges()
    @state = ( @state == :open ? :closed : :open )
  end

  # add a person to the displayed list of committers
  def add(person)
    person.date = 'pending'
    @committers << person
    @state = :closed
  end
end

#
# Show a committer
#

class PPMCCommitter < React
  def initialize
    @state = :closed
  end

  def render
    _tr onDoubleClick: self.select do

      if @@person.member
        _td { _b { _a @@person.id, href: "committer/#{@@person.id}"} }
        _td { _b @@person.name }
      else
        _td { _a @@person.id, href: "committer/#{@@person.id}" }
        _td @@person.name
      end

      if @state == :open
        _td data_ids: @@person.id do 
          if @@person.date == 'pending'
            _button.btn.btn_primary 'Add as a committer only',
              data_action: 'add committer', 
              data_target: '#confirm', data_toggle: 'modal',
              data_confirmation: "Grant #{@@person.name} committer access?"

            _button.btn.btn_success 'Add as a committer and to the PPMC',
              data_action: 'add ppmc committer', 
              data_target: '#confirm', data_toggle: 'modal',
              data_confirmation: "Add #{@@person.name} to the " +
                 "#{@@ppmc.display_name} PPMC and grant committer access?"
          else
            _button.btn.btn_warning 'Remove as Committer',
              data_action: 'remove committer', 
              data_target: '#confirm', data_toggle: 'modal',
              data_confirmation: "Remove #{@@person.name} as a Committer?"

            _button.btn.btn_primary 'Add to PPMC',
              data_action: 'add ppmc', 
              data_target: '#confirm', data_toggle: 'modal',
              data_confirmation: "Add #{@@person.name} to the " +
                "#{@@ppmc.display_name} PPMC?"
          end
        end
      else
        _td ''
      end
    end
  end

  # update props on initial load
  def componentWillMount()
    self.componentWillReceiveProps()
  end

  # automatically open pending entries
  def componentWillReceiveProps(newprops)
    @state = :closed if newprops.person.id != self.props.person.id
    @state = :open if @@person.date == 'pending'
  end

  # toggle display of buttons
  def select()
    return unless @@auth
    window.getSelection().removeAllRanges()
    @state = ( @state == :open ? :closed : :open )
  end
end
