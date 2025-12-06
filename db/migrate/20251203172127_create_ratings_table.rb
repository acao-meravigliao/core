class CreateRatingsTable < ActiveRecord::Migration[8.1]
  def up
#    current_schema = ActiveRecord::Base.connection.current_schema
#    ActiveRecord::Base.connection.schema_search_path = "'ml', 'public'"

    create_table 'acao.rating_types', id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.string :symbol, null: false, limit: 16
      t.string :name
      t.timestamps
    end

    add_index 'acao.rating_types', [ :symbol ], unique: true

    rts = {}
    rts['TMG'] = Ygg::Acao::RatingType.create!(
      symbol: 'TMG',
      name: 'Touring Motor Glider',
    )

    rts['SLSS'] = Ygg::Acao::RatingType.create!(
      symbol: 'SLSS',
      name: 'Self-Launching Self-Sustaining',
    )

    rts['FI'] = Ygg::Acao::RatingType.create!(
      symbol: 'FI',
      name: 'Flight Instructor',
    )

    rts['TOW'] = Ygg::Acao::RatingType.create!(
      symbol: 'TOW',
      name: 'Traino Alianti',
    )

    Ygg::Acao::RatingType.create!(
      symbol: 'PAX',
      name: 'Trasporto Passeggeri',
    )

    tow_launch = Ygg::Acao::RatingType.create!(
      symbol: 'TOW_LAUNCH',
      name: 'Lancio al Traino',
    )

    Ygg::Acao::RatingType.create!(
      symbol: 'WINCH',
      name: 'Lancio al Traino',
    )

    add_column 'acao.license_ratings', 'rating_type_id', :uuid

    rts.each do |rt_symbol, rt|
      Ygg::Acao::License::Rating.where(type: rt_symbol).update_all(rating_type_id: rt.id)
    end

    remove_column 'acao.license_ratings', 'type'

    Ygg::Acao::License::Rating.connection.schema_cache.clear!
    Ygg::Acao::License::Rating.reset_column_information

    Ygg::Acao::License.where(type: 'SPL').each do |license|
      license.ratings.find_or_create_by!(rating_type: tow_launch)
    end

    change_column_null 'acao.license_ratings', 'rating_type_id', false

    add_index 'acao.license_ratings', [ :rating_type_id ]
    add_foreign_key 'acao.license_ratings', 'acao.rating_types', column: 'rating_type_id'

#    ActiveRecord::Base.connection.schema_search_path = current_schema
  end

  def down
    add_column 'acao.license_ratings', 'type', :string
    remove_column 'acao.license_ratings', 'rating_type_id'
    drop_table 'acao.rating_types'
  end
end
