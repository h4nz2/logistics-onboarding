class WarehouseFetcher
  def initialize(company)
    @company = company
  end

  def progress
    # Stub: replace with real integration sync logic later
    { total: 0, fetched: 0 }
  end
end
