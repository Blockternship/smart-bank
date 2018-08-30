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

const items = accounts.map(({ title, value, valuta }) => (
  <Box mt={2} display="flex" justifyContent="space-between">
    <Text fontSize="16px" fontWeight="500">
      {title}
    </Text>
    <Text fontSize="16px" fontWeight="500">
      {new Intl.NumberFormat('en-US').format(value) + ' ' + valuta}
    </Text>
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
        <Box
          m="1rem auto"
          maxWidth="48em"
          display="flex"
          justifyContent="center"
          flexDirection="column"
        >
          <Card
            display="flex"
            flexWrap="wrap"
            flexDirection="column"
            p={3}
            mt={2}
            width="100%"
          >
            <Box display="flex" justifyContent="space-between">
              <Text fontSize="20px" fontWeight="700">
                My accounts
              </Text>
              <Text fontSize="20px" fontWeight="700">
                Value
              </Text>
            </Box>
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
        </Box>
      </div>
    )
  }
}
