class ExtendedContentAuthorizer < ContentAuthorizer
  def self.creatable_by? user
    true
  end
end
