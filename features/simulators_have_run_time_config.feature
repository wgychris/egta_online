Feature: Simulators have a default configuration
  In order to have simple run time configuration
  As a user
  I want my simulator to be instantiated with a default configuration

Background:
  Given I am signed in
  
Scenario: Simulator is uploaded successfully
  Given I am on the simulators page
  And one account that has passed group validation
  When I follow "New Simulator"
  And I fill in the following:
    | Name        | epp_sim                 |
    | Version     | test123                 |
    | Description | A simulator for testing |
  And I attach the file "features/support/epp_sim.zip" to "Simulator source"
  And I press "Create Simulator"
  Then I should be on the last simulator's page
  And I should see "epp_sim"
  And I should see "test123"
  And I should not see "error"



