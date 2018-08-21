import React, { Component } from 'react'

import { Trail, animated } from 'react-spring'
import { Link } from '../components/Icons'
import Badge from '../components/Badge'
import Box from '../components/Box'
import Layout from '../components/Layout'
import Navbar from '../components/Navbar'
import Card from '../components/Card'
import Text from '../components/Text'

export default class App extends Component {
  static async getInitialProps({ query }) {
    return query
  }

  render() {
    return (
      <div>
        <Navbar activeIndex={2} />
        <Layout display="flex" justifyContent="center">
          <Box display="flex" flexWrap="wrap">
            <Card p={3} m={3}>
              <Text>Settings</Text>
            </Card>
          </Box>
        </Layout>
      </div>
    )
  }
}
