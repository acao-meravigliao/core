class FixIpKlasses < ActiveRecord::Migration[6.0]
  def change
    Ygg::Core::Klass::MembersRoleDef.all.each { |x| x.attrs.transform_keys! { |k| k.gsub(/_string$/, '') } ; x.save! }
  end
end
