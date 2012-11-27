require 'digest/sha1'

module ApiKey

  TROLL_CONSTANT = "chupacabra"

  def self.generate(user)
    input = [Time.now.to_i, user.id, TROLL_CONSTANT].join(":;")
    Digest::SHA1.hexdigest(input)
  end

end