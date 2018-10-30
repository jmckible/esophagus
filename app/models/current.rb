class Current < ActiveSupport::CurrentAttributes
  attribute :cookbook, :user

  def user=(user)
    super
    self.cookbook = user.cookbook
  end

end
