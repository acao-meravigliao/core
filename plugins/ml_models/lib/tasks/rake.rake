
namespace :ygg do
namespace :ml do

task(:chores => :environment) do
  Ygg::Ml::Msg.queue_flush!
end

end
end
