class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  devise :omniauthable, :omniauth_providers => [:facebook]

  # organized meeting
  has_many :meetings, class_name: 'Event', foreign_key: :organizer_id
 

  # participating event
  has_many :event_users, class_name: 'Event_User',foreign_key: :participant_id
  has_many :events, through: :event_users
   has_many :itineraries, through: :events

  has_many :comments

	def self.from_omniauth(auth)
	      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        user.name = auth.info.name 
	      user.email = auth.info.email
	      user.password = Devise.friendly_token[0,20]
    	end      
  end

  def upcoming_itineraries
    self.itineraries.select do |itin| 
      if itin.meet_day >= DateTime.now && self.event_users.find_by(event_id: itin.event.id).going == "yes"
        itin
      end
    end

  end

end
