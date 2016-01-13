class CreateCityManagers < ActiveRecord::Migration
  def change
    create_table :city_managers do |t|
      t.integer :user_id
      t.integer :category
      t.string  :city
      t.decimal :rate, :precision => 2, :scale => 2
      t.datetime :settled_at

      t.timestamps null: false
    end

    say_with_time "Executing rake city_manager:migrate ..." do
      # Rails.application.load_tasks
      Rake::Task["city_manager:migrate"].invoke
    end

    say "Create CityManager Role"
    UserRole.find_or_create_by(name: 'city_manager', display_name: '城市运营商')
  end
end
