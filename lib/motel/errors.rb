module Motel

  class ExistingTenantError < StandardError
    def initialize(msg = "Existing tenant")
      super(msg)
    end
  end

  class NonexistentTenantError < StandardError
    def initialize(msg = "Nonexistent tenant")
      super(msg)
    end
  end

  class NoCurrentTenantError < StandardError
    def initialize(msg = "No current tenant")
      super(msg)
    end
  end

  class AnonymousTenantError < StandardError
    def initialize(msg = "Anonymous tenant is not allowed")
      super(msg)
    end
  end

end

