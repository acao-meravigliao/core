class AddMemberRolesTable < ActiveRecord::Migration[8.0]
  def up
    current_schema = ActiveRecord::Base.connection.current_schema
    ActiveRecord::Base.connection.schema_search_path = "'acao', 'public'"

    create_table 'member_roles', id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.uuid 'member_id'
      t.string 'symbol', limit: 32, null: false
      t.string 'name'
      t.timestamp 'valid_from'
      t.timestamp 'valid_to'
    end

    add_index 'member_roles', [ :member_id, :symbol ], unique: true
    add_index 'member_roles', [ :member_id ]

    add_foreign_key 'member_roles', 'members', column: 'member_id', on_delete: :cascade

    Ygg::Acao::Member.all.each do |member|
      member.roles.find_or_create_by(symbol: 'TUG_PILOT') if member.is_tug_pilot
      member.roles.find_or_create_by(symbol: 'SPL_STUDENT') if member.is_student
      member.roles.find_or_create_by(symbol: 'SPL_INSTRUCTOR') if member.is_instructor
      member.roles.find_or_create_by(symbol: 'BOARD_MEMBER') if member.is_board_member
      member.roles.find_or_create_by(symbol: 'FIREMAN') if member.is_fireman
    end

    ActiveRecord::Base.connection.schema_search_path = current_schema
  end

  def down
    drop_table 'acao.member_roles'
  end
end
