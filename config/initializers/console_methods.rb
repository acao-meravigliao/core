module Rails::ConsoleMethods
  def pilots(s)
    res = Ygg::Acao::Member.where('lower(last_name) = ?', s.downcase)
    return res if res.count > 1

    res = Ygg::Acao::Member.where('last_name ILIKE ?', '%' + s.downcase + '%')
    return res if res.count > 1

    res = Ygg::Acao::Member.where('lower(last_name) = ? AND lower(first_name) = ?',
                           s.split(' ').last.downcase, s.split(' ').first.downcase)
    return res if res.count > 1

    return nil
  end

  def pilota(s)
    res = Ygg::Acao::Member.find_by(code: s.is_a?(Numeric) ? s : (s.match(/[0-9]+/) && s.to_i))
    if res
      return res
    else
      return nil
    end

    res = pilots(s)
    raise "Multiple results" if res.count > 1
    return res.first if res.count == 1

    return nil
  end

  alias_method :pilot, :pilota
end
