# Summary

The script can be run in the Terminal.
```
ruby match_users.rb <matching_type> [matching_type] <csv_file>
```

## Validations
Checks for at least 2 parameters - matching type and input file

Checks if the file exists and a CSV file

Only accepts `email` and `phone` as matching type

## Specs
The output file will contain `user_id` which would be the unique group id

Matching using just one matcher type will group users by the matcher type taking into account the additional column

Matching using both matchers types will have users sharing any email or phone grouped together

Phone number only takes account the numbers to ignore formatting

Email is converted to lowercase when checking to case variations are ignored

## Potential future updates
The `user_id` in the output is not guaranteed to be in sequential order and can be updated to be in sequential order. If sequential IDs pose a security or privacy concern (e.g., inference of user count or relationships), they can be replaced with random or hashed unique identifiers instead.

Adding more matching types

Fuzzy matching

Further processing the phone (e.g. detect country code) and email (e.g. remove periods and detect + in Gmail addresses)
