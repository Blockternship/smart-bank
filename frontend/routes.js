const routes = (module.exports = require('next-routes')())

routes.add('/', 'index')
routes.add('/overview', 'index')
routes.add('/transactions', 'transactions')
routes.add('/settings', 'settings')
