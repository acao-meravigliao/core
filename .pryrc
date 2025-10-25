# Pry.config.commands.command 'persons', 'Get persons by name, code, ecc' do |s|

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
  if s.is_a?(Numeric)
    res = Ygg::Acao::Member.find_by(code: s)
    return res if res
  elsif s.match(/[0-9]+/)
    res = Ygg::Acao::Member.find_by(code: s.to_i)
    return res if res
  end

  res = persons(s)
  return nil if res.count == 0
  raise "Multiple results" if res.count > 1
  res.first.acao_member
end

alias pilota pilot

####################

def aircrafts(s)
  res = Ygg::Acao::Aircraft.where('lower(registration) = ?', s.downcase)
  return res if res.count > 0

  res = Ygg::Core::Person.where('registration ILIKE ?', '%' + s.downcase + '%')
  return res if res.count > 0

  return []
end

def aircraft(s)
  res = aircrafts(s)
  return nil if res.count == 0
  raise "Multiple results" if res.count > 1
  res.first
end

def aircrafts(s)
  res = Ygg::Acao::Aircraft.where('lower(registration) = ?', s.downcase)
  return res if res.count > 0

  res = Ygg::Acao::Aircraft.where('registration ILIKE ?', '%' + s.downcase + '%')
  return res if res.count > 0

  return []
end

def aircraft(s)
  res = aircrafts(s)
  return nil if res.count == 0
  raise "Multiple results" if res.count > 1
  res.first
end

####################

def glflight(s)
  Ygg::Acao::Flight.find_by(source_id: s, source_expansion: 'GL')
end

def towflight(s)
  Ygg::Acao::Flight.find_by(source_id: s, source_expansion: 'TOW')
end

def volo(s)
  Ygg::Acao::MainDb::Volo.find(s)
end
