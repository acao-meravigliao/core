
namespace :ygg do
namespace :ca do
  task(:chores => :environment) do
    Ygg::Ca::LeSlot.run_chores
    Ygg::Ca::LeOrder.run_chores
  end
end
end
