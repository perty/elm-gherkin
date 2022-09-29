@1.0
Feature: Navigation
  The navigation is when the ship moves. It is initiated with the
  command "NAV" and prompted course and warp factor.

  The course is a direction numbered from decimal 1.0 to 9.0 where
  9.0 is equal to 1.0, being full circle.

  The warp factor is the amount power to apply in that direction.
  A warp of 1.0 will certainly make the ship go to the next quadrant.
  Less than 1.0 may keep the ship within the quadrant.

  As the ship travels through the quadrant, it may run into obstacles.
  It may be a star, klingon or starbase. If that happens, the ship
  stops and message about bad navigation is displayed.

  If the ship is placed in a position next to a star base, it is
  considered docked.

  Scenario: Crashing into a star while moving
    Given a quadrant at 3,5
    And starship is located at sector 3,5
    And a star is located at sector 3,7
    When issuing command NAV 1.0 1.0
    Then starship is moved to sector 3,6
    And there is a message containing "BAD NAVIGATION"

  Scenario Outline: Moving within the quadrant
    Given a quadrant at 2,4
    And starship is located at sector <start row>,<start col>
    When issuing command NAV <course> <warp>
    Then starship is moved to sector <end row>,<end col>

    Examples:
      | start row | start col | course | warp | end row | end col |
      | 1         | 1         | 1.0    | 0.5  | 1       | 5       |
      | 8         | 1         | 2.0    | 0.5  | 4       | 5       |
      | 8         | 1         | 3.0    | 0.5  | 4       | 1       |
      | 8         | 8         | 4.0    | 0.5  | 4       | 4       |
      | 8         | 8         | 5.0    | 0.5  | 8       | 4       |
      | 1         | 8         | 6.0    | 0.5  | 5       | 4       |
      | 1         | 8         | 7.0    | 0.5  | 5       | 8       |
      | 1         | 1         | 8.0    | 0.5  | 5       | 5       |

  Scenario Outline: Moving across quadrant boundaries
    Given a quadrant at 4,4
    And starship is located at sector 1,1
    When issuing command NAV <course> <warp>
    Then starship is moved to sector <sector row>,<sector col>
    And starship is moved to quadrant <quadrant row>,<quadrant col>

    Examples:
      | course | warp | sector row | sector col | quadrant row | quadrant col |
      | 1.0    | 1    | 1          | 1          | 4            | 5            |
      | 5.0    | 0.5  | 1          | 5          | 4            | 3            |
      | 3.0    | 0.5  | 5          | 1          | 3            | 4            |
      | 3.0    | 2    | 1          | 1          | 2            | 4            |
      | 3.0    | 2.5  | 5          | 1          | 1            | 4            |






