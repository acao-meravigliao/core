require 'securerandom'

namespace :acao do
  desc 'Sync tables'

  task(:'sync:planes' => :environment) do

    Ygg::Acao::MainDb::Mezzo.where('numero_flarm <> \'id\'').all.each do |mezzo|

      registration = mezzo.Marche.strip.upcase
      flarm_id = mezzo.numero_flarm.strip.upcase

      puts "UPD #{flarm_id} = #{registration}"

      p = Ygg::Acao::Plane.find_by_flarm_id('flarm:' + flarm_id)
      if !p
        Ygg::Acao::Plane.create(
          registration: registration,
          flarm_id: 'flarm:' + flarm_id,
          uuid: SecureRandom.uuid,
        )
      else
        p.registration = mezzo.Marche.strip.upcase
        p.save!
      end

    end

  end
end

