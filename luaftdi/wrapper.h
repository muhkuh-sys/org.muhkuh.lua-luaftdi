
#ifdef __cplusplus
extern "C" {
#endif
#include "ftdi.h"
// #include "ftdi_i.h" <- non public only...
#include "lua.h"
#ifdef __cplusplus
}
#endif


#include <stdint.h>


#ifndef SWIGRUNTIME
#include <swigluarun.h>
#endif



#ifndef __WRAPPER_H__
#define __WRAPPER_H__

#if defined(SWIG)
typedef struct
{
    int major;
    int minor;
    int micro;
    char *version_str;
    char *snapshot_str;
} FTDI_VERSION_INFO_T;
#else
typedef struct ftdi_version_info FTDI_VERSION_INFO_T;
#endif

FTDI_VERSION_INFO_T get_library_version(void);




class ListEntry
{
public:
	ListEntry(struct ftdi_context *ptContext, struct ftdi_device_list *ptDevice);
	~ListEntry(void);

	uint8_t get_bus_number(void);
	void get_port_number(lua_State *MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, unsigned int *uiNUMBER_OF_CREATED_OBJECTS);
	void get_port_numbers(lua_State *MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, unsigned int *uiNUMBER_OF_CREATED_OBJECTS);
	void get_device_address(lua_State *MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, unsigned int *uiNUMBER_OF_CREATED_OBJECTS);

	void get_manufacturer(lua_State *MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, unsigned int *uiNUMBER_OF_CREATED_OBJECTS);
	void get_description(lua_State *MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, unsigned int *uiNUMBER_OF_CREATED_OBJECTS);
	void get_serial(lua_State *MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT_LIST, unsigned int *uiNUMBER_OF_CREATED_OBJECTS);

	struct libusb_device *get_usb_device(void);

private:
	int get_strings(void);

	struct ftdi_context *m_ptContext;
	struct libusb_device *m_ptUsbDevice;
	char *m_pcManufacturer;
	char *m_pcDescription;
	char *m_pcSerial;
};



class List
{
public:
	List(struct ftdi_context *ptContext, struct ftdi_device_list *ptDevlist);
	~List(void);

	ListEntry *next(void);
	void iter(lua_State *MUHKUH_SWIG_OUTPUT_CUSTOM_OBJECT, swig_type_info *p_ListEntry);

	static int iterator_next(lua_State *ptLuaState);

private:
	struct ftdi_context *m_ptContext;
	struct ftdi_device_list *m_ptDevlist;
	struct ftdi_device_list *m_ptCurrentDevice;
};



class TransferControl
{
public:
	TransferControl(struct ftdi_transfer_control *ptTransferControl);
	~TransferControl(void);

	int data_done(void);
	void data_cancel(long seconds, long useconds);

	void get_buffer(char **ppcBUFFER_OUT, size_t *psizBUFFER_OUT);
	int get_size(void);
	int get_offset(void);

private:
	struct ftdi_transfer_control *m_ptTransferControl;
};



typedef int RESULT_INT_TRUE_OR_NIL_WITH_ERR;
typedef int RESULT_INT_NOTHING_OR_NIL_WITH_ERR;

#if 0
class Eeprom
{
public:
	Eeprom(struct ftdi_context *ptContext);

	int initdefaults(char * manufacturer, char *product, char *serial);
	int set_strings(char *manufacturer, char *product, char *serial);
	int get_manufacturer(char **ppcBUFFER_OUT, size_t *psizBUFFER_OUT);
	int get_product(char **ppcBUFFER_OUT, size_t *psizBUFFER_OUT);
	int get_serial(char **ppcBUFFER_OUT, size_t *psizBUFFER_OUT);

	int build(void);
	int decode(int verbose);
	int get_value(enum ftdi_eeprom_value value_name, int *piARGUMENT_OUT);
	int set_value(enum ftdi_eeprom_value value_name, int value);
	int get_buf(char **ppcBUFFER_OUT, size_t *psizBUFFER_OUT);
	int set_buf(const char *pcBUFFER_IN, size_t sizBUFFER_IN);
	int set_user_data(const char *pcBUFFER_IN, size_t sizBUFFER_IN);
	int read_location(int eeprom_addr, unsigned short *pusARGUMENT_OUT);
	int write_location(int eeprom_addr, unsigned short eeprom_val);
	int read();
	int write();
	int erase();
	int read_chipid(unsigned int *puiARGUMENT_OUT);

	const char *get_error_string(void);


private:
	struct ftdi_context *m_ptContext;
};
#endif


class Context
{
public:
	Context(void);
	~Context(void);

	/* Device detection. */
	List *usb_find_all(int vendor, int product);

	/* Device opening / closing. */
	RESULT_INT_TRUE_OR_NIL_WITH_ERR usb_open_dev(ListEntry *ptDevice);
	RESULT_INT_TRUE_OR_NIL_WITH_ERR usb_open(int vendor, int product);
	RESULT_INT_TRUE_OR_NIL_WITH_ERR usb_open_desc(int vendor, int product, const char *description, const char *serial);
	RESULT_INT_TRUE_OR_NIL_WITH_ERR usb_open_desc_index(int vendor, int product, const char *description, const char *serial, unsigned int index);
	RESULT_INT_TRUE_OR_NIL_WITH_ERR usb_open_bus_addr(uint8_t bus, uint8_t addr);
	RESULT_INT_TRUE_OR_NIL_WITH_ERR usb_open_string(const char *description);
	RESULT_INT_TRUE_OR_NIL_WITH_ERR usb_close(void);

	RESULT_INT_TRUE_OR_NIL_WITH_ERR set_interface(enum ftdi_interface interface);
	RESULT_INT_TRUE_OR_NIL_WITH_ERR usb_reset(void);
	RESULT_INT_TRUE_OR_NIL_WITH_ERR usb_purge_rx_buffer(void);
	RESULT_INT_TRUE_OR_NIL_WITH_ERR usb_purge_tx_buffer(void);
	RESULT_INT_TRUE_OR_NIL_WITH_ERR usb_purge_buffers(void);

	RESULT_INT_TRUE_OR_NIL_WITH_ERR set_baudrate(int baudrate);
	RESULT_INT_TRUE_OR_NIL_WITH_ERR set_line_property(enum ftdi_bits_type bits, enum ftdi_stopbits_type sbit, enum ftdi_parity_type parity);
	RESULT_INT_TRUE_OR_NIL_WITH_ERR set_line_property(enum ftdi_bits_type bits, enum ftdi_stopbits_type sbit, enum ftdi_parity_type parity, enum ftdi_break_type break_type);
	RESULT_INT_TRUE_OR_NIL_WITH_ERR set_bitmode(unsigned char bitmask, unsigned char mode);
	RESULT_INT_TRUE_OR_NIL_WITH_ERR disable_bitbang(void);
	RESULT_INT_TRUE_OR_NIL_WITH_ERR set_latency_timer(unsigned char latency);
	RESULT_INT_NOTHING_OR_NIL_WITH_ERR get_latency_timer(unsigned char *pucARGUMENT_OUT);
	RESULT_INT_TRUE_OR_NIL_WITH_ERR setflowctrl(int flowctrl);
	RESULT_INT_TRUE_OR_NIL_WITH_ERR setdtr(int state);
	RESULT_INT_TRUE_OR_NIL_WITH_ERR setrts(int state);
	RESULT_INT_TRUE_OR_NIL_WITH_ERR setdtr_rts(int dtr, int rts);
	RESULT_INT_TRUE_OR_NIL_WITH_ERR set_event_char(unsigned char eventch, unsigned char enable);
	RESULT_INT_TRUE_OR_NIL_WITH_ERR set_error_char(unsigned char errorch, unsigned char enable);

	RESULT_INT_NOTHING_OR_NIL_WITH_ERR read_data(char **ppcBUFFER_OUT, size_t *psizBUFFER_OUT, size_t sizRead);
	TransferControl *read_data_submit(size_t sizRead);
	RESULT_INT_NOTHING_OR_NIL_WITH_ERR read_pins(unsigned char *pucARGUMENT_OUT);
	RESULT_INT_TRUE_OR_NIL_WITH_ERR write_data(const char *pcBUFFER_IN, size_t sizBUFFER_IN);
	TransferControl *write_data_submit(const char *pcBUFFER_IN, size_t sizBUFFER_IN);
	RESULT_INT_NOTHING_OR_NIL_WITH_ERR poll_modem_status(unsigned short *pusARGUMENT_OUT);

	RESULT_INT_TRUE_OR_NIL_WITH_ERR read_data_set_chunksize(unsigned int chunksize);
	RESULT_INT_NOTHING_OR_NIL_WITH_ERR read_data_get_chunksize(unsigned int *puiARGUMENT_OUT);
	RESULT_INT_TRUE_OR_NIL_WITH_ERR write_data_set_chunksize(unsigned int chunksize);
	RESULT_INT_NOTHING_OR_NIL_WITH_ERR write_data_get_chunksize(unsigned int *puiARGUMENT_OUT);

	const char *get_error_string(void);


private:
	struct ftdi_context *m_ptContext;
};


#endif  /* __WRAPPER_H__ */
