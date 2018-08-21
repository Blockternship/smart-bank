import React, { Component } from 'react'

import { Trail, animated } from 'react-spring'
import { Link } from '../components/Icons'
import Badge from '../components/Badge'
import Box from '../components/Box'
import Layout from '../components/Layout'
import Navbar from '../components/Navbar'
import Card from '../components/Card'
import Text from '../components/Text'

import accounts from '../data/accounts'

const items = accounts.map(account => (
  <Box>
    <Text>{account.title}</Text>
  </Box>
))

export default class App extends Component {
  static async getInitialProps({ query }) {
    return query
  }

  render() {
    return (
      <div>
        <Navbar activeIndex={0} />
        <Layout display="flex" justifyContent="center">
          <Card
            display="flex"
            flexWrap="wrap"
            flexDirection="column"
            p={3}
            mt={3}
          >
            <Text fontSize="20px" fontWeight="500">
              Accounts
            </Text>
            <Trail
              native
              from={{ opacity: 0 }}
              to={{ opacity: 1 }}
              keys={items}
            >
              {items.map(item => styles => (
                <animated.div style={styles}>{item}</animated.div>
              ))}
            </Trail>
          </Card>
        </Layout>
      </div>
    )
  }
}
