module Rails::ConsoleMethods
  def pilota(s)
    res = Ygg::Acao::Pilot.find_by(acao_code: s.is_a?(Numeric) ? s : (s.match(/[0-9]+/) && s.to_i))
    return res if res

    res = Ygg::Acao::Pilot.where('lower(last_name) = ?', s.downcase)
    raise "Multiple results" if res.count > 1
    return res.first if res.count == 1

    res = Ygg::Acao::Pilot.where('last_name ILIKE ?', '%' + s.downcase + '%')
    raise "Multiple results" if res.count > 1
    return res.first if res.count == 1

    res = Ygg::Acao::Pilot.where('lower(last_name) = ? AND lower(first_name) = ?',
                           s.split(' ').last.downcase, s.split(' ').first.downcase)
    raise "Multiple results" if res.count > 1
    return res.first if res.count == 1

    return nil
  end

  alias_method :pilot, :pilota
end
