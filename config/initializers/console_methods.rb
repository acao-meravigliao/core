module Rails::ConsoleMethods
  def pilota(s)
    res = Ygg::Acao::Pilot.find_by(acao_code: s.match(/[0-9]+/) && s.to_i)
    return res if res

    res = Ygg::Acao::Pilot.where('lower(last_name) = ?', s.downcase)
    return res if res.count == 1

    res = Ygg::Acao::Pilot.where('lower(last_name) = ? AND lower(first_name) = ?',
                           s.split(' ').last.downcase, s.split(' ').first.downcase)
    return res if res.count == 1

    return nil
  end
end
