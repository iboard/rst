
# Monkeypatch string with some useful methods
class String
  # @return [Boolean] - true if self is empty or filled with spaces only
  def blank?
    self.strip == ''
  end
end

