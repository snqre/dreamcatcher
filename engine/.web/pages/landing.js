import { Fragment, useContext, useEffect, useRef, useState } from "react"
import { useRouter } from "next/router"
import { Event, getAllLocalStorageItems, getRefValue, getRefValues, isTrue, preventDefault, refs, spreadArraysOrObjects, uploadFiles, useEventLoop } from "/utils/state"
import { ColorModeContext, EventLoopContext, initialEvents, StateContext } from "/utils/context.js"
import range from "/utils/helpers/range.js"
import "focus-visible/dist/focus-visible"
import { Box, Heading, HStack, Image, Menu, MenuButton, Modal, ModalBody, ModalContent, ModalHeader, ModalOverlay, Spacer, Text, VStack, Wrap } from "@chakra-ui/react"
import { getEventURL } from "/utils/state.js"
import NextHead from "next/head"



export default function Component() {
  const state = useContext(StateContext)
  const router = useRouter()
  const [ colorMode, toggleColorMode ] = useContext(ColorModeContext)
  const focusRef = useRef();
  
  // Main event loop.
  const [addEvents, connectError] = useContext(EventLoopContext)

  // Set focus to the specified element.
  useEffect(() => {
    if (focusRef.current) {
      focusRef.current.focus();
    }
  })

  // Route after the initial page hydration.
  useEffect(() => {
    const change_complete = () => addEvents(initialEvents())
    router.events.on('routeChangeComplete', change_complete)
    return () => {
      router.events.off('routeChangeComplete', change_complete)
    }
  }, [router])


  return (
    <Fragment>
  <Fragment>
  {isTrue(connectError !== null) ? (
  <Fragment>
  <Modal isOpen={connectError !== null}>
  <ModalOverlay>
  <ModalContent>
  <ModalHeader>
  {`Connection Error`}
</ModalHeader>
  <ModalBody>
  <Text>
  {`Cannot connect to server: `}
  {(connectError !== null) ? connectError.message : ''}
  {`. Check if server is reachable at `}
  {getEventURL().href}
</Text>
</ModalBody>
</ModalContent>
</ModalOverlay>
</Modal>
</Fragment>
) : (
  <Fragment/>
)}
</Fragment>
  <Wrap>
  <Box>
  <VStack>
  <Box sx={{"position": "fixed", "width": "100%", "top": "10px", "zIndex": "5"}}>
  <HStack spacing={`50px`}>
  <Spacer/>
  <HStack>
  <Image src={`/favicon.ico`}/>
  <Heading>
  {`Dreamcatcher`}
</Heading>
</HStack>
  <Spacer/>
  <Menu>
  <MenuButton>
  {`Home`}
</MenuButton>
  <MenuButton>
  {`Metrics`}
</MenuButton>
  <MenuButton>
  {`Team`}
</MenuButton>
  <MenuButton>
  {`Whitepaper`}
</MenuButton>
</Menu>
  <Spacer/>
</HStack>
</Box>
</VStack>
</Box>
</Wrap>
  <NextHead>
  <title>
  {`Reflex App`}
</title>
  <meta content={`A Reflex app.`} name={`description`}/>
  <meta content={`favicon.ico`} property={`og:image`}/>
</NextHead>
</Fragment>
  )
}
