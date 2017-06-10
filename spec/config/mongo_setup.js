// https://docs.mongodb.com/manual/tutorial/write-scripts-for-the-mongo-shell/
// https://docs.mongodb.com/manual/core/security-users/

db = new Mongo().getDB('dumper_test_db')
// db.dropUser('dumper_test_user')
if (db.getUser('dumper_test_user') == null) {
  db.createUser({user: 'dumper_test_user', pwd: 'dumper_test_password', roles: [{role: 'read', db: 'dumper_test_db'}]})
}
if (db.auth('dumper_test_user', 'dumper_test_password')) {
  print('authentication with dumper_test_user succeeded!')
}
