class AddConditionIdToTrips < ActiveRecord::Migration[5.0]
  def change
    add_reference :trips, :condition, foreign_key: true
  end

end
