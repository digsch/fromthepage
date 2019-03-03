require 'spec_helper'


RSpec.describe AdminMailer::OwnerCollectionActivity do
  describe ".build" do
      before :all do
        @owner = create(:user)
        @collection = create(:collection, owner_user_id: @owner.id)
        @new_collaborator = create(:user)
        @old_collaborator = create(:user)
      end
  
      after :each do
        @new_deed.destroy if @new_deed
        @old_deed.destroy if @old_deed
      end
  
      after :all do
        @owner.destroy
        @collection.destroy
        @new_collaborator.destroy
        @old_collaborator.destroy
      end
  
      it "stores the owner as an attribute" do
        activity = AdminMailer::OwnerCollectionActivity.build(@owner)
        expect(activity.owner).to eq(@owner)
      end
      
      it "retrieves owner collections and sets as an attribute" do
        activity = AdminMailer::OwnerCollectionActivity.build(@owner)
        expect(activity.collections.first).to eq(@collection)
      end
      
      it "retrieves new owner collaborators and sets as an attribute" do
        @new_deed = create(:deed, {
          deed_type: DeedType::WORK_ADDED,
          collection_id: @collection.id,
          user_id: @new_collaborator.id
        })
        activity = AdminMailer::OwnerCollectionActivity.build(@owner)
        expect(activity.collaborators.first).to eq(@new_collaborator)
        expect(activity.collaborators.last).to eq(@new_collaborator)
      end
      
      it "ensures it doesn't include old collaborators" do
        @new_deed = create(:deed, {
          deed_type: DeedType::WORK_ADDED,
          collection_id: @collection.id,
          user_id: @old_collaborator.id
        })
        @old_deed = create(:deed, {
          deed_type: DeedType::WORK_ADDED,
          collection_id: @collection.id,
          user_id: @old_collaborator.id,
          created_at: 2.days.ago
        })
        @new_collaborator_deed = create(:deed, {
          deed_type: DeedType::WORK_ADDED,
          collection_id: @collection.id,
          user_id: @new_collaborator.id
        })

        activity = AdminMailer::OwnerCollectionActivity.build(@owner)
        expect(activity.collaborators.length).to eq(1)
        expect(activity.collaborators.first).to eq(@new_collaborator)
        
        @new_collaborator_deed.destroy
      end
  end
end