def person(s)
  res = Ygg::Core::Person.where('lower(last_name) = ?', s.downcase)
  raise "Multiple results" if res.count > 1
  return res.first if res.count == 1

  res = Ygg::Core::Person.where('lower(last_name) = ? AND lower(first_name) = ?',
                         s.split(' ').last.downcase, s.split(' ').first.downcase)
  raise "Multiple results" if res.count > 1
  return res.first if res.count == 1

  return nil
end

def pilot(s)
  res = Ygg::Acao::Member.find_by(code: s.is_a?(Numeric) ? s : (s.match(/[0-9]+/) && s.to_i))
  return res if res

  return person(s)
end

alias pilota pilot
alias member pilot
