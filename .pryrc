def persons(s)
  res = Ygg::Core::Person.where('lower(last_name) = ?', s.downcase)
  return res if res.count > 0

  res = Ygg::Core::Person.where('last_name ILIKE ?', '%' + s.downcase + '%')
  return res if res.count > 0

  res = Ygg::Core::Person.where('lower(last_name) = ? AND lower(first_name) = ?',
                         s.split(' ').last.downcase, s.split(' ').first.downcase)
  return res if res.count > 0

  return []
end

def person(s)
  res = persons(s)
  return nil if res.count == 0
  raise "Multiple results" if res.count > 1
  res.first
end

def pilot(s)
  res = Ygg::Acao::Member.find_by(code: s.is_a?(Numeric) ? s : (s.match(/[0-9]+/) && s.to_i))
  return res if res

  res = persons(s)
  return nil if res.count == 0
  raise "Multiple results" if res.count > 1
  res.first.acao_member
end

alias pilota pilot
