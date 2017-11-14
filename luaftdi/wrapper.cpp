#include "wrapper.h"
#include "libusb.h"

FTDI_VERSION_INFO_T get_library_version(void)
{
	return ftdi_get_library_version();
}



ListEntry::ListEntry(struct ftdi_context *ptContext, struct ftdi_device_list *ptDevice)
 : m_ptContext(ptContext)
 , m_ptUsbDevice(NULL)
 , m_pcManufacturer(NULL)
 , m_pcDescription(NULL)
 , m_pcSerial(NULL)
{
	if( ptDevice!=NULL )
	{
		/* Get the USB device and reference it. */
		m_ptUsbDevice = ptDevice->dev;
		libusb_ref_device(m_ptUsbDevice);
	}
}



ListEntry::~ListEntry(void)
{
	m_ptContext = NULL;

	if( m_ptUsbDevice!=NULL )
	{
		libusb_unref_device(m_ptUsbDevice);
		m_ptUsbDevice = NULL;
	}

	if( m_pcManufacturer!=NULL )
	{
		free(m_pcManufacturer);
		m_pcManufacturer = NULL;
	}

	if( m_pcDescription!=NULL )
	{
		free(m_pcDescription);
		m_pcDescription = NULL;
	}

	if( m_pcSerial!=NULL )
	{
		free(m_pcSerial);
		m_pcSerial = NULL;
	}
}



uint8_t ListEntry::get_bus_number(void)
{
	uint8_t uiResult;


	uiResult = 0;
	if( m_ptUsbDevice!=NULL )
	{
		uiResult = libusb_get_bus_number(m_ptUsbDevice);
	}

	return uiResult;
}



void ListEntry::get_port_number(lua_State *MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, unsigned int *uiNUMBER_OF_CREATED_OBJECTS)
{
	int iNumberOfReturnValues;
	uint8_t uiResult;


	if( m_ptUsbDevice==NULL )
	{
		lua_pushnil(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST);
		lua_pushstring(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, "Invalid list entry");
		iNumberOfReturnValues = 2;
	}
	else
	{
		uiResult = libusb_get_port_number(m_ptUsbDevice);
		lua_pushnumber(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, uiResult);
		iNumberOfReturnValues = 1;
	}

	*uiNUMBER_OF_CREATED_OBJECTS = iNumberOfReturnValues;
}



void ListEntry::get_port_numbers(lua_State *MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, unsigned int *uiNUMBER_OF_CREATED_OBJECTS)
{
	int iNumberOfReturnValues;
	int iResult;
	int iNumberOfPathElements;
	uint8_t auiPorts[7];
	int iCnt;


	if( m_ptUsbDevice==NULL )
	{
		lua_pushnil(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST);
		lua_pushstring(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, "Invalid list entry");
		iNumberOfReturnValues = 2;
	}
	else
	{
		iResult = libusb_get_port_numbers(m_ptUsbDevice, auiPorts, sizeof(auiPorts));
		if( iResult<0 )
		{
			lua_pushnil(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST);
			lua_pushstring(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, libusb_error_name(iResult));
			iNumberOfReturnValues = 2;
		}
		else
		{
			iNumberOfPathElements = iResult;
			lua_createtable(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, iNumberOfPathElements, 0);

			for(iCnt=0; iCnt<iNumberOfPathElements; ++iCnt)
			{
				lua_pushnumber(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, iCnt+1);
				lua_pushnumber(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, auiPorts[iCnt]);
				lua_settable(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, -3);
			}

			iNumberOfReturnValues = 1;
		}
	}

	*uiNUMBER_OF_CREATED_OBJECTS = iNumberOfReturnValues;
}



void ListEntry::get_device_address(lua_State *MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, unsigned int *uiNUMBER_OF_CREATED_OBJECTS)
{
	int iNumberOfReturnValues;
	uint8_t uiResult;


	if( m_ptUsbDevice==NULL )
	{
		lua_pushnil(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST);
		lua_pushstring(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, "Invalid list entry");
		iNumberOfReturnValues = 2;
	}
	else
	{
		uiResult = libusb_get_device_address(m_ptUsbDevice);
		lua_pushnumber(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, uiResult);
		iNumberOfReturnValues = 1;
	}

	*uiNUMBER_OF_CREATED_OBJECTS = iNumberOfReturnValues;
}



int ListEntry::get_strings(void)
{
	char *pcManufacturer;
	const size_t sizManufacturerMax = 1024;
	char *pcDescription;
	const size_t sizDescriptionMax = 1024;
	char *pcSerial;
	const size_t sizSerialMax = 1024;
	int iResult;


	iResult = -1;
	pcManufacturer = NULL;
	pcDescription = NULL;
	pcSerial = NULL;

	pcManufacturer = (char*)malloc(sizManufacturerMax);
	if( pcManufacturer!=NULL )
	{
		pcDescription = (char*)malloc(sizDescriptionMax);
		if( pcDescription!=NULL )
		{
			pcSerial = (char*)malloc(sizSerialMax);
			if( pcSerial!=NULL )
			{
				iResult = 0;
			}
		}
	}

	if( iResult==0 )
	{
		iResult = ftdi_usb_get_strings2(m_ptContext, m_ptUsbDevice, pcManufacturer, sizManufacturerMax, pcDescription, sizDescriptionMax, pcSerial, sizSerialMax);
		if( iResult==0 )
		{
			if( m_pcManufacturer!=NULL )
			{
				free(m_pcManufacturer);
			}
			m_pcManufacturer = pcManufacturer;

			if( m_pcDescription!=NULL )
			{
				free(m_pcDescription);
			}
			m_pcDescription = pcDescription;

			if( m_pcSerial!=NULL )
			{
				free(m_pcSerial);
			}
			m_pcSerial = pcSerial;
		}
	}
	else
	{
		if( pcManufacturer!=NULL )
		{
			free(pcManufacturer);
		}
		if( pcDescription!=NULL )
		{
			free(pcDescription);
		}
		if( pcSerial!=NULL )
		{
			free(pcSerial);
		}
	}

	return iResult;
}



void ListEntry::get_manufacturer(lua_State *MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, unsigned int *uiNUMBER_OF_CREATED_OBJECTS)
{
	int iNumberOfReturnValues;
	int iResult;


	if( m_ptUsbDevice==NULL )
	{
		lua_pushnil(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST);
		lua_pushstring(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, "Invalid list entry");
		iNumberOfReturnValues = 2;
	}
	else
	{
		iResult = get_strings();
		if( iResult!=0 )
		{
			lua_pushnil(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST);
			lua_pushstring(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, ftdi_get_error_string(m_ptContext));
			iNumberOfReturnValues = 2;
		}
		else
		{
			lua_pushstring(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, m_pcManufacturer);
			iNumberOfReturnValues = 1;
		}
	}

	*uiNUMBER_OF_CREATED_OBJECTS = iNumberOfReturnValues;
}



void ListEntry::get_description(lua_State *MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, unsigned int *uiNUMBER_OF_CREATED_OBJECTS)
{
	int iNumberOfReturnValues;
	int iResult;


	if( m_ptUsbDevice==NULL )
	{
		lua_pushnil(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST);
		lua_pushstring(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, "Invalid list entry");
		iNumberOfReturnValues = 2;
	}
	else
	{
		iResult = get_strings();
		if( iResult!=0 )
		{
			lua_pushnil(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST);
			lua_pushstring(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, ftdi_get_error_string(m_ptContext));
			iNumberOfReturnValues = 2;
		}
		else
		{
			lua_pushstring(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, m_pcDescription);
			iNumberOfReturnValues = 1;
		}
	}

	*uiNUMBER_OF_CREATED_OBJECTS = iNumberOfReturnValues;
}



void ListEntry::get_serial(lua_State *MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, unsigned int *uiNUMBER_OF_CREATED_OBJECTS)
{
	int iNumberOfReturnValues;
	int iResult;


	if( m_ptUsbDevice==NULL )
	{
		lua_pushnil(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST);
		lua_pushstring(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, "Invalid list entry");
		iNumberOfReturnValues = 2;
	}
	else
	{
		iResult = get_strings();
		if( iResult!=0 )
		{
			lua_pushnil(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST);
			lua_pushstring(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, ftdi_get_error_string(m_ptContext));
			iNumberOfReturnValues = 2;
		}
		else
		{
			lua_pushstring(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, m_pcSerial);
			iNumberOfReturnValues = 1;
		}
	}

	*uiNUMBER_OF_CREATED_OBJECTS = iNumberOfReturnValues;
}



struct libusb_device *ListEntry::get_usb_device(void)
{
	return m_ptUsbDevice;
}



List::List(struct ftdi_context *ptContext, struct ftdi_device_list *ptDevlist)
 : m_ptContext(ptContext)
 , m_ptDevlist(ptDevlist)
 , m_ptCurrentDevice(ptDevlist)
{
}


List::~List(void)
{
	m_ptContext = NULL;

	if( m_ptDevlist!=NULL )
	{
		ftdi_list_free(&m_ptDevlist);
		m_ptDevlist = NULL;
	}
}



ListEntry *List::next(void)
{
	ListEntry *ptNext;


	ptNext = NULL;

	if( m_ptCurrentDevice!=NULL )
	{
		ptNext = new ListEntry(m_ptContext, m_ptCurrentDevice);
		m_ptCurrentDevice = m_ptCurrentDevice->next;
	}

	return ptNext;
}



void List::iter(lua_State *MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT, swig_type_info *p_ListEntry)
{
	/* Push the pointer to this instance of the "List" class as the first up-value. */
	lua_pushlightuserdata(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT, (void*)this);
	/* Push the type of the result as the second up-value. */
	lua_pushlightuserdata(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT, (void*)p_ListEntry);
	/* Create a C closure with 2 arguments. */
	lua_pushcclosure(MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT, &(List::iterator_next), 2);

	/* NOTE: This function does not return the produced number of
	 *       arguments. This is done in the SWIG wrapper.
	 */
}



int List::iterator_next(lua_State *ptLuaState)
{
	int iUpvalueIndex;
	void *pvUpvalue;
	List *ptThis;
	swig_type_info *ptTypeInfo;
	ListEntry *ptListEntry;


	/* Get the first up-value. */
	iUpvalueIndex = lua_upvalueindex(1);
	pvUpvalue = lua_touserdata(ptLuaState, iUpvalueIndex);
	/* Cast the up-value to a class pointer. */
	ptThis = (List*)pvUpvalue;

	/* Get the second up-value. */
	iUpvalueIndex = lua_upvalueindex(2);
	pvUpvalue = lua_touserdata(ptLuaState, iUpvalueIndex);
	ptTypeInfo = (swig_type_info*)pvUpvalue;

	/* Get the next list entry. */
	ptListEntry = ptThis->next();
	/* Push the class on the LUA stack. */
	if( ptListEntry==NULL )
	{
		lua_pushnil(ptLuaState);
	}
	else
	{
		/* Create a new pointer object from the list entry and transfer the ownership to LUA (this is the last parameter). */
		SWIG_NewPointerObj(ptLuaState, ptListEntry, ptTypeInfo, 1);
	}

	return 1;
}



TransferControl::TransferControl(struct ftdi_transfer_control *ptTransferControl)
 : m_ptTransferControl(ptTransferControl)
{
}



TransferControl::~TransferControl(void)
{
}



int TransferControl::data_done(void)
{
	int iResult;


	if( m_ptTransferControl==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_transfer_data_done(m_ptTransferControl);
	}

	return iResult;
}



void TransferControl::data_cancel(long seconds, long useconds)
{
	struct timeval tTime;


	if( m_ptTransferControl!=NULL )
	{
		tTime.tv_sec = seconds;
		tTime.tv_usec = useconds;

		ftdi_transfer_data_cancel(m_ptTransferControl, &tTime);
	}
}


void TransferControl::get_buffer(char **ppcBUFFER_OUT, size_t *psizBUFFER_OUT)
{
	char *pcBuffer;
	size_t sizBuffer;


	if( m_ptTransferControl==NULL )
	{
		pcBuffer = NULL;
		sizBuffer = 0;
	}
	else
	{
		pcBuffer = (char*)(m_ptTransferControl->buf);
		sizBuffer = m_ptTransferControl->size;
	}

	*ppcBUFFER_OUT = pcBuffer;
	*psizBUFFER_OUT = sizBuffer;
}



int TransferControl::get_size(void)
{
	int iResult;


	if( m_ptTransferControl==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = m_ptTransferControl->size;
	}

	return iResult;
}


int TransferControl::get_offset(void)
{
	int iResult;


	if( m_ptTransferControl==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = m_ptTransferControl->offset;
	}

	return iResult;
}



Context::Context(void)
 : m_ptContext(NULL)
{
	m_ptContext = ftdi_new();
}



Context::~Context(void)
{
	if( m_ptContext!=NULL )
	{
		ftdi_free(m_ptContext);
		m_ptContext = NULL;
	}
}

List *Context::usb_find_all(int vendor, int product)
{
	List *ptResult;
	int iResult;
	struct ftdi_device_list *ptDevlist;


	/* Be pessimistic... */
	ptResult = NULL;

	if( m_ptContext!=NULL )
	{
		iResult = ftdi_usb_find_all(m_ptContext, &ptDevlist, vendor, product);
		if( iResult>=0 )
		{
			ptResult = new List(m_ptContext, ptDevlist);
		}
	}

	return ptResult;
}



int Context::usb_open_dev(ListEntry *ptDevice)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else if( ptDevice==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_usb_open_dev(m_ptContext, ptDevice->get_usb_device());
	}

	return iResult;
}



int Context::usb_open(int vendor, int product)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_usb_open(m_ptContext, vendor, product);
	}

	return iResult;
}



int Context::usb_open_desc(int vendor, int product, const char *description, const char *serial)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_usb_open_desc(m_ptContext, vendor, product, description, serial);
	}

	return iResult;
}



int Context::usb_open_desc_index(int vendor, int product, const char *description, const char *serial, unsigned int index)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_usb_open_desc_index(m_ptContext, vendor, product, description, serial, index);
	}

	return iResult;
}



int Context::usb_open_bus_addr(uint8_t bus, uint8_t addr)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_usb_open_bus_addr(m_ptContext, bus, addr);
	}

	return iResult;
}



int Context::usb_open_string(const char *description)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_usb_open_string(m_ptContext, description);
	}

	return iResult;
}



int Context::usb_close(void)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_usb_close(m_ptContext);
	}

	return iResult;
}



int Context::set_interface(enum ftdi_interface interface)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_set_interface(m_ptContext, interface);
	}

	return iResult;
}



int Context::usb_reset(void)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_usb_reset(m_ptContext);
	}

	return iResult;
}



int Context::usb_purge_rx_buffer(void)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_usb_purge_rx_buffer(m_ptContext);
	}

	return iResult;
}



int Context::usb_purge_tx_buffer(void)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_usb_purge_tx_buffer(m_ptContext);
	}

	return iResult;
}



int Context::usb_purge_buffers(void)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_usb_purge_buffers(m_ptContext);
	}

	return iResult;
}



int Context::set_baudrate(int baudrate)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_set_baudrate(m_ptContext, baudrate);
	}

	return iResult;
}



int Context::set_line_property(enum ftdi_bits_type bits, enum ftdi_stopbits_type sbit, enum ftdi_parity_type parity)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_set_line_property(m_ptContext, bits, sbit, parity);
	}

	return iResult;
}


int Context::set_line_property(enum ftdi_bits_type bits, enum ftdi_stopbits_type sbit, enum ftdi_parity_type parity, enum ftdi_break_type break_type)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_set_line_property2(m_ptContext, bits, sbit, parity, break_type);
	}

	return iResult;
}


int Context::set_bitmode(unsigned char bitmask, unsigned char mode)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_set_bitmode(m_ptContext, bitmask, mode);
	}

	return iResult;
}


int Context::disable_bitbang(void)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_disable_bitbang(m_ptContext);
	}

	return iResult;
}


int Context::set_latency_timer(unsigned char latency)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_set_latency_timer(m_ptContext, latency);
	}

	return iResult;
}


int Context::get_latency_timer(unsigned char *pucARGUMENT_OUT)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_get_latency_timer(m_ptContext, pucARGUMENT_OUT);
	}

	return iResult;
}


int Context::setflowctrl(int flowctrl)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_setflowctrl(m_ptContext, flowctrl);
	}

	return iResult;
}


int Context::setdtr(int state)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_setdtr(m_ptContext, state);
	}

	return iResult;
}


int Context::setrts(int state)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_setrts(m_ptContext, state);
	}

	return iResult;
}


int Context::setdtr_rts(int dtr, int rts)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_setdtr_rts(m_ptContext, dtr, rts);
	}

	return iResult;
}


int Context::set_event_char(unsigned char eventch, unsigned char enable)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_set_event_char(m_ptContext, eventch, enable);
	}

	return iResult;
}


int Context::set_error_char(unsigned char errorch, unsigned char enable)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_set_error_char(m_ptContext, errorch, enable);
	}

	return iResult;
}



int Context::read_data(char **ppcBUFFER_OUT, size_t *psizBUFFER_OUT, size_t sizRead)
{
	int iResult;
	unsigned char *pucBuffer;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		pucBuffer = (unsigned char*)malloc(sizRead);
		if( pucBuffer==NULL )
		{
			iResult = -1;
		}
		else
		{
			iResult = ftdi_read_data(m_ptContext, pucBuffer, sizRead);
			if( iResult<0 )
			{
				free(pucBuffer);
			}
			else
			{
				*ppcBUFFER_OUT = (char*)pucBuffer;
				*psizBUFFER_OUT = iResult;
			}
		}
	}

	return iResult;
}



TransferControl *Context::read_data_submit(size_t sizRead)
{
	struct ftdi_transfer_control *ptTc;
	TransferControl *ptTransferControl;
	unsigned char *pucBuffer;


	if( m_ptContext==NULL )
	{
		ptTransferControl = NULL;
	}
	else
	{
		pucBuffer = (unsigned char*)malloc(sizRead);
		if( pucBuffer==NULL )
		{
			ptTransferControl = NULL;
		}
		else
		{
			ptTc = ftdi_read_data_submit(m_ptContext, pucBuffer, sizRead);
			if( ptTc==NULL )
			{
				free(pucBuffer);
				ptTransferControl = NULL;
			}
			else
			{
				ptTransferControl = new TransferControl(ptTc);
			}
		}
	}

	return ptTransferControl;
}



int Context::read_pins(unsigned char *pucARGUMENT_OUT)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_read_pins(m_ptContext, pucARGUMENT_OUT);
	}

	return iResult;
}



int Context::write_data(const char *pcBUFFER_IN, size_t sizBUFFER_IN)
{
	int iResult;
	const unsigned char *pucBuffer;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		pucBuffer = (const unsigned char*)pcBUFFER_IN;
		iResult = ftdi_write_data(m_ptContext, pucBuffer, sizBUFFER_IN);
	}

	return iResult;
}



TransferControl *Context::write_data_submit(const char *pcBUFFER_IN, size_t sizBUFFER_IN)
{
	unsigned char *pucBuffer;
	struct ftdi_transfer_control *ptTc;
	TransferControl *ptTransferControl;


	if( m_ptContext==NULL )
	{
		ptTransferControl = NULL;
	}
	else
	{
		pucBuffer = (unsigned char*)pcBUFFER_IN;
		ptTc = ftdi_write_data_submit(m_ptContext, pucBuffer, sizBUFFER_IN);
		if( ptTc==NULL )
		{
			ptTransferControl = NULL;
		}
		else
		{
			ptTransferControl = new TransferControl(ptTc);
		}
	}

	return ptTransferControl;
}



int Context::poll_modem_status(unsigned short *pusARGUMENT_OUT)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_poll_modem_status(m_ptContext, pusARGUMENT_OUT);
	}

	return iResult;
}



int Context::read_data_set_chunksize(unsigned int chunksize)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_read_data_set_chunksize(m_ptContext, chunksize);
	}

	return iResult;
}



int Context::read_data_get_chunksize(unsigned int *puiARGUMENT_OUT)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_read_data_get_chunksize(m_ptContext, puiARGUMENT_OUT);
	}

	return iResult;
}



int Context::write_data_set_chunksize(unsigned int chunksize)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_write_data_set_chunksize(m_ptContext, chunksize);
	}

	return iResult;
}



int Context::write_data_get_chunksize(unsigned int *puiARGUMENT_OUT)
{
	int iResult;


	if( m_ptContext==NULL )
	{
		iResult = -1;
	}
	else
	{
		iResult = ftdi_write_data_get_chunksize(m_ptContext, puiARGUMENT_OUT);
	}

	return iResult;
}



const char *Context::get_error_string(void)
{
	const char *pcErrorString;


	if( m_ptContext==NULL )
	{
		pcErrorString = "No context available.";
	}
	else
	{
		pcErrorString = ftdi_get_error_string(m_ptContext);
	}

	return pcErrorString;
}

