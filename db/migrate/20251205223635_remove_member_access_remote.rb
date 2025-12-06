class RemoveMemberAccessRemote < ActiveRecord::Migration[8.1]

  class MemberAccessRemote < ActiveRecord::Base
    self.table_name = 'acao.member_access_remotes'

    belongs_to :member,
             class_name: 'Ygg::Acao::Member'

    belongs_to :remote,
             class_name: 'Ygg::Acao::AccessRemote'
  end

  def up
    add_column 'acao.access_remotes', 'member_id', :uuid
    add_index 'acao.access_remotes', [ :member_id ]
    add_foreign_key 'acao.access_remotes', 'acao.members', column: 'member_id'

    MemberAccessRemote.all.each do |mar|
      mar.remote.update!(member_id: mar.member_id)
    end

    drop_table 'acao.member_access_remotes'
  end
end
