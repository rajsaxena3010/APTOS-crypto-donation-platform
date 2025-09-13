module MyModule::DonationPlatform {
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing a donation campaign
    struct DonationCampaign has store, key {
        total_donations: u64,  // Total amount donated to the campaign
        description: vector<u8>,  // Campaign description
        is_active: bool,       // Whether the campaign is accepting donations
    }

    /// Error codes
    const E_CAMPAIGN_NOT_ACTIVE: u64 = 1;
    const E_CAMPAIGN_NOT_FOUND: u64 = 2;

    /// Function to create a new donation campaign
    public fun create_campaign(creator: &signer, description: vector<u8>) {
        let campaign = DonationCampaign {
            total_donations: 0,
            description,
            is_active: true,
        };
        move_to(creator, campaign);
    }

    /// Function to donate to a campaign
    public fun donate(donor: &signer, campaign_owner: address, amount: u64) acquires DonationCampaign {
        // Check if campaign exists
        assert!(exists<DonationCampaign>(campaign_owner), E_CAMPAIGN_NOT_FOUND);
        
        let campaign = borrow_global_mut<DonationCampaign>(campaign_owner);
        
        // Check if campaign is active
        assert!(campaign.is_active, E_CAMPAIGN_NOT_ACTIVE);
        
        // Transfer donation from donor to campaign owner
        let donation = coin::withdraw<AptosCoin>(donor, amount);
        coin::deposit<AptosCoin>(campaign_owner, donation);
        
        // Update total donations
        campaign.total_donations = campaign.total_donations + amount;
    }
}