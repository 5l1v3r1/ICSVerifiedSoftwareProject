/*
 * Copyright 2017, Data61
 * Commonwealth Scientific and Industrial Research Organisation (CSIRO)
 * ABN 41 687 119 230.
 *
 * This software may be distributed and modified according to the terms of
 * the BSD 2-Clause license. Note that NO WARRANTY is provided.
 * See "LICENSE_BSD2.txt" for details.
 *
 * @TAG(DATA61_BSD)
 */



#include <camkes/dataport.h>











  
    
    
    
    
        
            
            
            
            
        
    
    
    
    
    
    

    

    
    
    

    
    
    
    
        
        
        
            
        
    
        
        
        
            
        
    

    
    
    
        
            
                
            
                
            
            
        
    
        
            
                
                    
                
            
                
            
            
        
    

    
    

    
    



/*
 * Copyright 2017, Data61
 * Commonwealth Scientific and Industrial Research Organisation (CSIRO)
 * ABN 41 687 119 230.
 *
 * This software may be distributed and modified according to the terms of
 * the BSD 2-Clause license. Note that NO WARRANTY is provided.
 * See "LICENSE_BSD2.txt" for details.
 *
 * @TAG(DATA61_BSD)
 */








#include <sel4/sel4.h>
#include <assert.h>
#include <limits.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <sync/sem-bare.h>
#include <camkes/dataport.h>
#include <camkes/error.h>
#include <camkes/tls.h>









/* Interface-specific error handling */


    
    
    

    /* The currently active error handler. This variable is marked UNUSED to squash
     * compiler warnings generated when the user's build configuration causes the
     * two following functions to be pruned from the final source.
    */
    static camkes_error_handler_t signtx_iface_error_handler_fn UNUSED;

    camkes_error_handler_t signtx_iface_register_error_handler(
        camkes_error_handler_t handler) {
        camkes_error_handler_t old = signtx_iface_error_handler_fn;
        signtx_iface_error_handler_fn = handler;
        return old;
    }

    static camkes_error_action_t UNUSED signtx_iface_error_handler(camkes_error_t *error) {
        if (signtx_iface_error_handler_fn == NULL) {
            /* No registered handler; invoke the generic error handler. */
            return camkes_error(error);
        }
        return signtx_iface_error_handler_fn(error);
    }



    
    
    
        
        
            
                
        
  
  
  static void _camkes__488(void) NO_INLINE UNUSED
    WARNING("typedef char * looks like an array (unsupported) and should be wrapped in a struct");
  static void _camkes__488(void) {
    /* We need something opaque here to prevent the compiler from optimising
     * away an invocation of (and hence the warning attached to) this function.
     * This is also why this function is marked noinline.
     */
    asm volatile ("");
  }
  static void SigntxIface_print_sign_text_array_typedef_check(char * x UNUSED)
    UNUSED;
  static void SigntxIface_print_sign_text_array_typedef_check(char * x UNUSED) {
    __builtin_choose_expr(

      
      sizeof(x) != sizeof(char *) ||

      
      (sizeof(char *) == sizeof(void*) &&
        (__builtin_types_compatible_p(char[sizeof(void*)], char *) ||
         __builtin_types_compatible_p(signed char[sizeof(void*)], char *) ||
         __builtin_types_compatible_p(unsigned char[sizeof(void*)], char *) ||
         __builtin_types_compatible_p(short[sizeof(void*) / sizeof(short)], char *) ||
         __builtin_types_compatible_p(unsigned short[sizeof(void*) / sizeof(unsigned short)], char *) ||
         __builtin_types_compatible_p(int[sizeof(void*) / sizeof(int)], char *) ||
         __builtin_types_compatible_p(unsigned[sizeof(void*) / sizeof(unsigned)], char *) ||
         __builtin_types_compatible_p(long[sizeof(void*) / sizeof(long)], char *) ||
         __builtin_types_compatible_p(unsigned long[sizeof(void*) / sizeof(unsigned long)], char *) ||
         (sizeof(void*) / sizeof(long long) > 0 &&
           __builtin_types_compatible_p(long long[sizeof(void*) / sizeof(long long)], char *)) ||
         (sizeof(void*) / sizeof(unsigned long long) > 0 &&
           __builtin_types_compatible_p(unsigned long long[sizeof(void*) / sizeof(unsigned long long)], char *)) ||
         (sizeof(void*) / sizeof(double) > 0 &&
           __builtin_types_compatible_p(double[sizeof(void*) / sizeof(double)], char *)) ||
         (sizeof(void*) / sizeof(long double) > 0 &&
           __builtin_types_compatible_p(long double[sizeof(void*) / sizeof(long double)], char *)) ||
         (sizeof(void*) / sizeof(float) > 0 &&
           __builtin_types_compatible_p(float[sizeof(void*) / sizeof(float)], char *)))),

      /* trigger a compile-time warning: */ _camkes__488(),
      /* do nothing: */ (void)0);
  }

    
                
            
        
            
        
            
                
        
  
  
  static void _camkes__489(void) NO_INLINE UNUSED
    WARNING("typedef int looks like an array (unsupported) and should be wrapped in a struct");
  static void _camkes__489(void) {
    /* We need something opaque here to prevent the compiler from optimising
     * away an invocation of (and hence the warning attached to) this function.
     * This is also why this function is marked noinline.
     */
    asm volatile ("");
  }
  static void SigntxIface_print_sign_id_array_typedef_check(int x UNUSED)
    UNUSED;
  static void SigntxIface_print_sign_id_array_typedef_check(int x UNUSED) {
    __builtin_choose_expr(

      
      sizeof(x) != sizeof(int) ||

      
      (sizeof(int) == sizeof(void*) &&
        (__builtin_types_compatible_p(char[sizeof(void*)], int) ||
         __builtin_types_compatible_p(signed char[sizeof(void*)], int) ||
         __builtin_types_compatible_p(unsigned char[sizeof(void*)], int) ||
         __builtin_types_compatible_p(short[sizeof(void*) / sizeof(short)], int) ||
         __builtin_types_compatible_p(unsigned short[sizeof(void*) / sizeof(unsigned short)], int) ||
         __builtin_types_compatible_p(int[sizeof(void*) / sizeof(int)], int) ||
         __builtin_types_compatible_p(unsigned[sizeof(void*) / sizeof(unsigned)], int) ||
         __builtin_types_compatible_p(long[sizeof(void*) / sizeof(long)], int) ||
         __builtin_types_compatible_p(unsigned long[sizeof(void*) / sizeof(unsigned long)], int) ||
         (sizeof(void*) / sizeof(long long) > 0 &&
           __builtin_types_compatible_p(long long[sizeof(void*) / sizeof(long long)], int)) ||
         (sizeof(void*) / sizeof(unsigned long long) > 0 &&
           __builtin_types_compatible_p(unsigned long long[sizeof(void*) / sizeof(unsigned long long)], int)) ||
         (sizeof(void*) / sizeof(double) > 0 &&
           __builtin_types_compatible_p(double[sizeof(void*) / sizeof(double)], int)) ||
         (sizeof(void*) / sizeof(long double) > 0 &&
           __builtin_types_compatible_p(long double[sizeof(void*) / sizeof(long double)], int)) ||
         (sizeof(void*) / sizeof(float) > 0 &&
           __builtin_types_compatible_p(float[sizeof(void*) / sizeof(float)], int)))),

      /* trigger a compile-time warning: */ _camkes__489(),
      /* do nothing: */ (void)0);
  }

    
                
            
        
            
        
            
        
    
        
        
            
        
            
        
            
        
            
        
    



int signtx_iface__run(void) {
    /* This function is never actually executed, but we still emit it for the
     * purpose of type checking RPC parameters.
     */
    UNREACHABLE();

    
    
    
    
    
        
        
            
                
        
  
  static char * _camkes__490;
  SigntxIface_print_sign_text_array_typedef_check(_camkes__490);

    
                
            
        
            
        
            
                
        
  
  static int _camkes__491;
  SigntxIface_print_sign_id_array_typedef_check(_camkes__491);

    
                
            
        
            
        
            
        
    
        
        
            
        
            
        
            
        
            
        
    


    return 0;
}





    
    
    
    
    
    
    
    
    
    
    
    

    
    
        
            
        
    
        
            
        
    
        
            
                
    /* The TLS_PTR macro is for acquiring a pointer to a local variable. The first
     * argument is the corresponding TLS global and the second is the local
     * variable you are taking the address of. The purpose of this abstraction is
     * to allow for varying TLS models.
     */
    #ifdef CONFIG_CAMKES_TLS_STANDARD

    #ifndef TLS_PTR
        #define TLS_PTR(tls_var, name) (&(name))
    #endif

    #elif defined(CONFIG_CAMKES_TLS_PTG)

    #ifndef TLS_PTR
        #define TLS_PTR(tls_var, name) (get_##tls_var())
    #endif

    #else

        #error undefined TLS model

    #endif

    
        
        static int print_sign_id_from_1
        
        UNUSED;
    
        
        static int print_sign_id_from_2
        
        UNUSED;
    
        
        static int print_sign_id_from_3
        
        UNUSED;
    
        
        static int print_sign_id_from_4
        
        UNUSED;
    

    static int *
    
    get_print_sign_id_from(void) UNUSED;
    static int *
    
    get_print_sign_id_from(void) {
        switch (camkes_get_tls()->thread_index) {
            
                case 1:
                    
                        return & print_sign_id_from_1;
                    
            
                case 2:
                    
                        return & print_sign_id_from_2;
                    
            
                case 3:
                    
                        return & print_sign_id_from_3;
                    
            
                case 4:
                    
                        return & print_sign_id_from_4;
                    
            
            default:
                assert(!"invalid thread index");
                abort();
        }
    }

            
        
    
        
            
                
    /* The TLS_PTR macro is for acquiring a pointer to a local variable. The first
     * argument is the corresponding TLS global and the second is the local
     * variable you are taking the address of. The purpose of this abstraction is
     * to allow for varying TLS models.
     */
    #ifdef CONFIG_CAMKES_TLS_STANDARD

    #ifndef TLS_PTR
        #define TLS_PTR(tls_var, name) (&(name))
    #endif

    #elif defined(CONFIG_CAMKES_TLS_PTG)

    #ifndef TLS_PTR
        #define TLS_PTR(tls_var, name) (get_##tls_var())
    #endif

    #else

        #error undefined TLS model

    #endif

    
        
        static int print_sign_isValid_from_1
        
        UNUSED;
    
        
        static int print_sign_isValid_from_2
        
        UNUSED;
    
        
        static int print_sign_isValid_from_3
        
        UNUSED;
    
        
        static int print_sign_isValid_from_4
        
        UNUSED;
    

    static int *
    
    get_print_sign_isValid_from(void) UNUSED;
    static int *
    
    get_print_sign_isValid_from(void) {
        switch (camkes_get_tls()->thread_index) {
            
                case 1:
                    
                        return & print_sign_isValid_from_1;
                    
            
                case 2:
                    
                        return & print_sign_isValid_from_2;
                    
            
                case 3:
                    
                        return & print_sign_isValid_from_3;
                    
            
                case 4:
                    
                        return & print_sign_isValid_from_4;
                    
            
            default:
                assert(!"invalid thread index");
                abort();
        }
    }

            
        
    
        
            
        
    
    

    
        
        
        static unsigned print_sign_marshal_inputs_text(unsigned _camkes_offset_492,
            
    
        
            const char *
        
        text
    

        ) {

        
        void * _camkes_buffer_base_493 UNUSED = (void*)(((void*)&seL4_GetIPCBuffer()->msg[0]));

        /* Construct parameter pointers. We do this here to consolidate where we
         * are taking the address of local variables. In future, we need to avoid
         * doing this for verification.
         */
        
        
        
        
        
            
                const char * _camkes_ptr_str_496 = text;
            
        

        
            
            size_t _camkes_strlen_498 = strnlen(_camkes_ptr_str_496, (seL4_MsgMaxLength * sizeof(seL4_Word)) - _camkes_offset_492);
            
            
    ERR_IF(_camkes_strlen_498 + 1 > (seL4_MsgMaxLength * sizeof(seL4_Word)) - _camkes_offset_492, signtx_iface_error_handler, ((camkes_error_t){
        .type = CE_BUFFER_LENGTH_EXCEEDED,
        .instance = "crypto",
        .interface = "signtx_iface",
        .description = "buffer exceeded while marshalling text in print_sign",
        .current_length = _camkes_offset_492,
        .target_length = _camkes_offset_492 + _camkes_strlen_498 + 1,
        }), ({
            return UINT_MAX;
    }));

            /* If we didn't trigger an error, we now know this strcpy is safe. */
            (void)strcpy(_camkes_buffer_base_493 + _camkes_offset_492, _camkes_ptr_str_496);
            _camkes_offset_492 += _camkes_strlen_498 + 1;
        
        return _camkes_offset_492;
    }
    
        
        
        static unsigned print_sign_marshal_inputs_source(unsigned _camkes_offset_499,
            
    
        
            const char *
        
        source
    

        ) {

        
        void * _camkes_buffer_base_500 UNUSED = (void*)(((void*)&seL4_GetIPCBuffer()->msg[0]));

        /* Construct parameter pointers. We do this here to consolidate where we
         * are taking the address of local variables. In future, we need to avoid
         * doing this for verification.
         */
        
        
        
        
        
            
                const char * _camkes_ptr_str_503 = source;
            
        

        
            
            size_t _camkes_strlen_505 = strnlen(_camkes_ptr_str_503, (seL4_MsgMaxLength * sizeof(seL4_Word)) - _camkes_offset_499);
            
            
    ERR_IF(_camkes_strlen_505 + 1 > (seL4_MsgMaxLength * sizeof(seL4_Word)) - _camkes_offset_499, signtx_iface_error_handler, ((camkes_error_t){
        .type = CE_BUFFER_LENGTH_EXCEEDED,
        .instance = "crypto",
        .interface = "signtx_iface",
        .description = "buffer exceeded while marshalling source in print_sign",
        .current_length = _camkes_offset_499,
        .target_length = _camkes_offset_499 + _camkes_strlen_505 + 1,
        }), ({
            return UINT_MAX;
    }));

            /* If we didn't trigger an error, we now know this strcpy is safe. */
            (void)strcpy(_camkes_buffer_base_500 + _camkes_offset_499, _camkes_ptr_str_503);
            _camkes_offset_499 += _camkes_strlen_505 + 1;
        
        return _camkes_offset_499;
    }
    
        
        
        static unsigned print_sign_marshal_inputs_id(unsigned _camkes_offset_506,
            
    
        
            int
        
        id
    

        ) {

        
        void * _camkes_buffer_base_507 UNUSED = (void*)(((void*)&seL4_GetIPCBuffer()->msg[0]));

        /* Construct parameter pointers. We do this here to consolidate where we
         * are taking the address of local variables. In future, we need to avoid
         * doing this for verification.
         */
        
        
        
        
        
            
                int * _camkes_ptr_508 = TLS_PTR(print_sign_id_from, id);
                * _camkes_ptr_508 = id;
            
        

        
            
            
    ERR_IF(sizeof(* _camkes_ptr_508) > (seL4_MsgMaxLength * sizeof(seL4_Word)) - _camkes_offset_506, signtx_iface_error_handler, ((camkes_error_t){
        .type = CE_BUFFER_LENGTH_EXCEEDED,
        .instance = "crypto",
        .interface = "signtx_iface",
        .description = "buffer exceeded while marshalling id in print_sign",
        .current_length = _camkes_offset_506,
        .target_length = _camkes_offset_506 + sizeof(* _camkes_ptr_508),
        }), ({
            return UINT_MAX;
    }));

            memcpy(_camkes_buffer_base_507 + _camkes_offset_506, _camkes_ptr_508, sizeof(* _camkes_ptr_508));
            _camkes_offset_506 += sizeof(* _camkes_ptr_508);
        
        return _camkes_offset_506;
    }
    
        
        
        static unsigned print_sign_marshal_inputs_isValid(unsigned _camkes_offset_512,
            
    
        
            int
        
        isValid
    

        ) {

        
        void * _camkes_buffer_base_513 UNUSED = (void*)(((void*)&seL4_GetIPCBuffer()->msg[0]));

        /* Construct parameter pointers. We do this here to consolidate where we
         * are taking the address of local variables. In future, we need to avoid
         * doing this for verification.
         */
        
        
        
        
        
            
                int * _camkes_ptr_514 = TLS_PTR(print_sign_isValid_from, isValid);
                * _camkes_ptr_514 = isValid;
            
        

        
            
            
    ERR_IF(sizeof(* _camkes_ptr_514) > (seL4_MsgMaxLength * sizeof(seL4_Word)) - _camkes_offset_512, signtx_iface_error_handler, ((camkes_error_t){
        .type = CE_BUFFER_LENGTH_EXCEEDED,
        .instance = "crypto",
        .interface = "signtx_iface",
        .description = "buffer exceeded while marshalling isValid in print_sign",
        .current_length = _camkes_offset_512,
        .target_length = _camkes_offset_512 + sizeof(* _camkes_ptr_514),
        }), ({
            return UINT_MAX;
    }));

            memcpy(_camkes_buffer_base_513 + _camkes_offset_512, _camkes_ptr_514, sizeof(* _camkes_ptr_514));
            _camkes_offset_512 += sizeof(* _camkes_ptr_514);
        
        return _camkes_offset_512;
    }
    
        
        
        static unsigned print_sign_marshal_inputs_hmac(unsigned _camkes_offset_518,
            
    
        
            const char *
        
        hmac
    

        ) {

        
        void * _camkes_buffer_base_519 UNUSED = (void*)(((void*)&seL4_GetIPCBuffer()->msg[0]));

        /* Construct parameter pointers. We do this here to consolidate where we
         * are taking the address of local variables. In future, we need to avoid
         * doing this for verification.
         */
        
        
        
        
        
            
                const char * _camkes_ptr_str_522 = hmac;
            
        

        
            
            size_t _camkes_strlen_524 = strnlen(_camkes_ptr_str_522, (seL4_MsgMaxLength * sizeof(seL4_Word)) - _camkes_offset_518);
            
            
    ERR_IF(_camkes_strlen_524 + 1 > (seL4_MsgMaxLength * sizeof(seL4_Word)) - _camkes_offset_518, signtx_iface_error_handler, ((camkes_error_t){
        .type = CE_BUFFER_LENGTH_EXCEEDED,
        .instance = "crypto",
        .interface = "signtx_iface",
        .description = "buffer exceeded while marshalling hmac in print_sign",
        .current_length = _camkes_offset_518,
        .target_length = _camkes_offset_518 + _camkes_strlen_524 + 1,
        }), ({
            return UINT_MAX;
    }));

            /* If we didn't trigger an error, we now know this strcpy is safe. */
            (void)strcpy(_camkes_buffer_base_519 + _camkes_offset_518, _camkes_ptr_str_522);
            _camkes_offset_518 += _camkes_strlen_524 + 1;
        
        return _camkes_offset_518;
    }
    

    
        
        static const uint8_t _camkes_method_index_525 = 0;
    

    static unsigned print_sign_marshal_inputs(
    
    
        
        
    
        
            const char *
        
        text
    

        
            ,
        
    
        
        
    
        
            const char *
        
        source
    

        
            ,
        
    
        
        
    
        
            int
        
        id
    

        
            ,
        
    
        
        
    
        
            int
        
        isValid
    

        
            ,
        
    
        
        
    
        
            const char *
        
        hmac
    

        
    

    
    ) {

        
        unsigned _camkes_length_526 = 0;

        
        void * _camkes_buffer_base_527 UNUSED = (void*)(((void*)&seL4_GetIPCBuffer()->msg[0]));

        
            /* Marshal the method index. */
            
            
    ERR_IF(sizeof(_camkes_method_index_525) > (seL4_MsgMaxLength * sizeof(seL4_Word)) - _camkes_length_526, signtx_iface_error_handler, ((camkes_error_t){
        .type = CE_BUFFER_LENGTH_EXCEEDED,
        .instance = "crypto",
        .interface = "signtx_iface",
        .description = "buffer exceeded while marshalling print_sign in print_sign",
        .current_length = _camkes_length_526,
        .target_length = _camkes_length_526 + sizeof(_camkes_method_index_525),
        }), ({
            return UINT_MAX;
    }));

            memcpy(_camkes_buffer_base_527, & _camkes_method_index_525, sizeof(_camkes_method_index_525));
            _camkes_length_526 += sizeof(_camkes_method_index_525);
        

        /* Marshal the parameters. */
        
            
            _camkes_length_526 = print_sign_marshal_inputs_text(_camkes_length_526,
            
            text
            );
            if (unlikely(_camkes_length_526 == UINT_MAX)) {
                return UINT_MAX;
            }
        
            
            _camkes_length_526 = print_sign_marshal_inputs_source(_camkes_length_526,
            
            source
            );
            if (unlikely(_camkes_length_526 == UINT_MAX)) {
                return UINT_MAX;
            }
        
            
            _camkes_length_526 = print_sign_marshal_inputs_id(_camkes_length_526,
            
            id
            );
            if (unlikely(_camkes_length_526 == UINT_MAX)) {
                return UINT_MAX;
            }
        
            
            _camkes_length_526 = print_sign_marshal_inputs_isValid(_camkes_length_526,
            
            isValid
            );
            if (unlikely(_camkes_length_526 == UINT_MAX)) {
                return UINT_MAX;
            }
        
            
            _camkes_length_526 = print_sign_marshal_inputs_hmac(_camkes_length_526,
            
            hmac
            );
            if (unlikely(_camkes_length_526 == UINT_MAX)) {
                return UINT_MAX;
            }
        

        assert(_camkes_length_526 <= (seL4_MsgMaxLength * sizeof(seL4_Word)) &&
            "uncaught buffer overflow while marshalling inputs for print_sign");

        return _camkes_length_526;
    }




    
    
    
    
    
    
    
    
    
    
    

    
    
    

    static int
    print_sign_unmarshal_outputs(
    
    unsigned _camkes_size_529
    
    
    

    
    

    ) {

        
        unsigned _camkes_length_531 UNUSED = 0;

        
        void * _camkes_buffer_base_532 UNUSED = (void*)(((void*)&seL4_GetIPCBuffer()->msg[0]));

        

        /* Unmarshal the parameters. */
        

        
        ERR_IF(ROUND_UP_UNSAFE(_camkes_length_531, sizeof(seL4_Word)) != _camkes_size_529, signtx_iface_error_handler, ((camkes_error_t){
            .type = CE_MALFORMED_RPC_PAYLOAD,
            .instance = "crypto",
            .interface = "signtx_iface",
            .description = "excess trailing bytes after unmarshalling parameters for print_sign",
            .length = _camkes_size_529,
            .current_index = _camkes_length_531,
            }), ({
                
                
                return -1;
        }));
    

    return 0;
    }






    void

signtx_iface_print_sign(

    
        
        
    
        
            const char *
        
        text
    

        
            ,
        
    
        
        
    
        
            const char *
        
        source
    

        
            ,
        
    
        
        
    
        
            int
        
        id
    

        
            ,
        
    
        
        
    
        
            int
        
        isValid
    

        
            ,
        
    
        
        
    
        
            const char *
        
        hmac
    

        
    

) {

    

    
    /* Save any pending reply cap as we'll eventually call seL4_Call which
     * could overwrite it. Note that we do this here before marshalling
     * parameters to ensure we don't inadvertently overwrite any marshalled
     * data with this call.
     */
    
        camkes_protect_reply_cap();
    
    


    
    
    

    /* Marshal all the parameters */
    
    unsigned _camkes_length_536 = 
    
    
    

    print_sign_marshal_inputs(
    
        
        text
        
            ,
        
    
        
        source
        
            ,
        
    
        
        id
        
            ,
        
    
        
        isValid
        
            ,
        
    
        
        hmac
        
    
    )
;
    if (unlikely(_camkes_length_536 == UINT_MAX)) {
        /* Error in marshalling; bail out. */
        
            return;
        
    }

    
    unsigned _camkes_size_537;
    
    /* Call the endpoint */
    
    seL4_MessageInfo_t _camkes_info_538 = seL4_MessageInfo_new(0, 0, 0,
        
                ROUND_UP_UNSAFE(_camkes_length_536, sizeof(seL4_Word)) / sizeof(seL4_Word)
        
        );
    _camkes_info_538 = seL4_Call(14, _camkes_info_538);

    _camkes_size_537 =
    
        seL4_MessageInfo_get_length(_camkes_info_538) * sizeof(seL4_Word);
        assert(_camkes_size_537 <= seL4_MsgMaxLength * sizeof(seL4_Word));
    


    /* Unmarshal the response */
    
    int _camkes_error_539 = 
    
    
    
    
    

    print_sign_unmarshal_outputs(
    _camkes_size_537
    
    
    
    )
;
    if (unlikely(_camkes_error_539 != 0)) {
        /* Error in unmarshalling; bail out. */
        
            return;
        
    }

    
    


    
}




    
    
    
    
    
    
    
    
    
    
    
    

    
    
        
            
        
    
        
            
        
    
        
            
                
    /* The TLS_PTR macro is for acquiring a pointer to a local variable. The first
     * argument is the corresponding TLS global and the second is the local
     * variable you are taking the address of. The purpose of this abstraction is
     * to allow for varying TLS models.
     */
    #ifdef CONFIG_CAMKES_TLS_STANDARD

    #ifndef TLS_PTR
        #define TLS_PTR(tls_var, name) (&(name))
    #endif

    #elif defined(CONFIG_CAMKES_TLS_PTG)

    #ifndef TLS_PTR
        #define TLS_PTR(tls_var, name) (get_##tls_var())
    #endif

    #else

        #error undefined TLS model

    #endif

    
        
        static int print_mod_id_from_1
        
        UNUSED;
    
        
        static int print_mod_id_from_2
        
        UNUSED;
    
        
        static int print_mod_id_from_3
        
        UNUSED;
    
        
        static int print_mod_id_from_4
        
        UNUSED;
    

    static int *
    
    get_print_mod_id_from(void) UNUSED;
    static int *
    
    get_print_mod_id_from(void) {
        switch (camkes_get_tls()->thread_index) {
            
                case 1:
                    
                        return & print_mod_id_from_1;
                    
            
                case 2:
                    
                        return & print_mod_id_from_2;
                    
            
                case 3:
                    
                        return & print_mod_id_from_3;
                    
            
                case 4:
                    
                        return & print_mod_id_from_4;
                    
            
            default:
                assert(!"invalid thread index");
                abort();
        }
    }

            
        
    
        
            
                
    /* The TLS_PTR macro is for acquiring a pointer to a local variable. The first
     * argument is the corresponding TLS global and the second is the local
     * variable you are taking the address of. The purpose of this abstraction is
     * to allow for varying TLS models.
     */
    #ifdef CONFIG_CAMKES_TLS_STANDARD

    #ifndef TLS_PTR
        #define TLS_PTR(tls_var, name) (&(name))
    #endif

    #elif defined(CONFIG_CAMKES_TLS_PTG)

    #ifndef TLS_PTR
        #define TLS_PTR(tls_var, name) (get_##tls_var())
    #endif

    #else

        #error undefined TLS model

    #endif

    
        
        static int print_mod_isValid_from_1
        
        UNUSED;
    
        
        static int print_mod_isValid_from_2
        
        UNUSED;
    
        
        static int print_mod_isValid_from_3
        
        UNUSED;
    
        
        static int print_mod_isValid_from_4
        
        UNUSED;
    

    static int *
    
    get_print_mod_isValid_from(void) UNUSED;
    static int *
    
    get_print_mod_isValid_from(void) {
        switch (camkes_get_tls()->thread_index) {
            
                case 1:
                    
                        return & print_mod_isValid_from_1;
                    
            
                case 2:
                    
                        return & print_mod_isValid_from_2;
                    
            
                case 3:
                    
                        return & print_mod_isValid_from_3;
                    
            
                case 4:
                    
                        return & print_mod_isValid_from_4;
                    
            
            default:
                assert(!"invalid thread index");
                abort();
        }
    }

            
        
    
    

    
        
        
        static unsigned print_mod_marshal_inputs_text(unsigned _camkes_offset_540,
            
    
        
            const char *
        
        text
    

        ) {

        
        void * _camkes_buffer_base_541 UNUSED = (void*)(((void*)&seL4_GetIPCBuffer()->msg[0]));

        /* Construct parameter pointers. We do this here to consolidate where we
         * are taking the address of local variables. In future, we need to avoid
         * doing this for verification.
         */
        
        
        
        
        
            
                const char * _camkes_ptr_str_544 = text;
            
        

        
            
            size_t _camkes_strlen_546 = strnlen(_camkes_ptr_str_544, (seL4_MsgMaxLength * sizeof(seL4_Word)) - _camkes_offset_540);
            
            
    ERR_IF(_camkes_strlen_546 + 1 > (seL4_MsgMaxLength * sizeof(seL4_Word)) - _camkes_offset_540, signtx_iface_error_handler, ((camkes_error_t){
        .type = CE_BUFFER_LENGTH_EXCEEDED,
        .instance = "crypto",
        .interface = "signtx_iface",
        .description = "buffer exceeded while marshalling text in print_mod",
        .current_length = _camkes_offset_540,
        .target_length = _camkes_offset_540 + _camkes_strlen_546 + 1,
        }), ({
            return UINT_MAX;
    }));

            /* If we didn't trigger an error, we now know this strcpy is safe. */
            (void)strcpy(_camkes_buffer_base_541 + _camkes_offset_540, _camkes_ptr_str_544);
            _camkes_offset_540 += _camkes_strlen_546 + 1;
        
        return _camkes_offset_540;
    }
    
        
        
        static unsigned print_mod_marshal_inputs_source(unsigned _camkes_offset_547,
            
    
        
            const char *
        
        source
    

        ) {

        
        void * _camkes_buffer_base_548 UNUSED = (void*)(((void*)&seL4_GetIPCBuffer()->msg[0]));

        /* Construct parameter pointers. We do this here to consolidate where we
         * are taking the address of local variables. In future, we need to avoid
         * doing this for verification.
         */
        
        
        
        
        
            
                const char * _camkes_ptr_str_551 = source;
            
        

        
            
            size_t _camkes_strlen_553 = strnlen(_camkes_ptr_str_551, (seL4_MsgMaxLength * sizeof(seL4_Word)) - _camkes_offset_547);
            
            
    ERR_IF(_camkes_strlen_553 + 1 > (seL4_MsgMaxLength * sizeof(seL4_Word)) - _camkes_offset_547, signtx_iface_error_handler, ((camkes_error_t){
        .type = CE_BUFFER_LENGTH_EXCEEDED,
        .instance = "crypto",
        .interface = "signtx_iface",
        .description = "buffer exceeded while marshalling source in print_mod",
        .current_length = _camkes_offset_547,
        .target_length = _camkes_offset_547 + _camkes_strlen_553 + 1,
        }), ({
            return UINT_MAX;
    }));

            /* If we didn't trigger an error, we now know this strcpy is safe. */
            (void)strcpy(_camkes_buffer_base_548 + _camkes_offset_547, _camkes_ptr_str_551);
            _camkes_offset_547 += _camkes_strlen_553 + 1;
        
        return _camkes_offset_547;
    }
    
        
        
        static unsigned print_mod_marshal_inputs_id(unsigned _camkes_offset_554,
            
    
        
            int
        
        id
    

        ) {

        
        void * _camkes_buffer_base_555 UNUSED = (void*)(((void*)&seL4_GetIPCBuffer()->msg[0]));

        /* Construct parameter pointers. We do this here to consolidate where we
         * are taking the address of local variables. In future, we need to avoid
         * doing this for verification.
         */
        
        
        
        
        
            
                int * _camkes_ptr_556 = TLS_PTR(print_mod_id_from, id);
                * _camkes_ptr_556 = id;
            
        

        
            
            
    ERR_IF(sizeof(* _camkes_ptr_556) > (seL4_MsgMaxLength * sizeof(seL4_Word)) - _camkes_offset_554, signtx_iface_error_handler, ((camkes_error_t){
        .type = CE_BUFFER_LENGTH_EXCEEDED,
        .instance = "crypto",
        .interface = "signtx_iface",
        .description = "buffer exceeded while marshalling id in print_mod",
        .current_length = _camkes_offset_554,
        .target_length = _camkes_offset_554 + sizeof(* _camkes_ptr_556),
        }), ({
            return UINT_MAX;
    }));

            memcpy(_camkes_buffer_base_555 + _camkes_offset_554, _camkes_ptr_556, sizeof(* _camkes_ptr_556));
            _camkes_offset_554 += sizeof(* _camkes_ptr_556);
        
        return _camkes_offset_554;
    }
    
        
        
        static unsigned print_mod_marshal_inputs_isValid(unsigned _camkes_offset_560,
            
    
        
            int
        
        isValid
    

        ) {

        
        void * _camkes_buffer_base_561 UNUSED = (void*)(((void*)&seL4_GetIPCBuffer()->msg[0]));

        /* Construct parameter pointers. We do this here to consolidate where we
         * are taking the address of local variables. In future, we need to avoid
         * doing this for verification.
         */
        
        
        
        
        
            
                int * _camkes_ptr_562 = TLS_PTR(print_mod_isValid_from, isValid);
                * _camkes_ptr_562 = isValid;
            
        

        
            
            
    ERR_IF(sizeof(* _camkes_ptr_562) > (seL4_MsgMaxLength * sizeof(seL4_Word)) - _camkes_offset_560, signtx_iface_error_handler, ((camkes_error_t){
        .type = CE_BUFFER_LENGTH_EXCEEDED,
        .instance = "crypto",
        .interface = "signtx_iface",
        .description = "buffer exceeded while marshalling isValid in print_mod",
        .current_length = _camkes_offset_560,
        .target_length = _camkes_offset_560 + sizeof(* _camkes_ptr_562),
        }), ({
            return UINT_MAX;
    }));

            memcpy(_camkes_buffer_base_561 + _camkes_offset_560, _camkes_ptr_562, sizeof(* _camkes_ptr_562));
            _camkes_offset_560 += sizeof(* _camkes_ptr_562);
        
        return _camkes_offset_560;
    }
    

    
        
        static const uint8_t _camkes_method_index_566 = 1;
    

    static unsigned print_mod_marshal_inputs(
    
    
        
        
    
        
            const char *
        
        text
    

        
            ,
        
    
        
        
    
        
            const char *
        
        source
    

        
            ,
        
    
        
        
    
        
            int
        
        id
    

        
            ,
        
    
        
        
    
        
            int
        
        isValid
    

        
    

    
    ) {

        
        unsigned _camkes_length_567 = 0;

        
        void * _camkes_buffer_base_568 UNUSED = (void*)(((void*)&seL4_GetIPCBuffer()->msg[0]));

        
            /* Marshal the method index. */
            
            
    ERR_IF(sizeof(_camkes_method_index_566) > (seL4_MsgMaxLength * sizeof(seL4_Word)) - _camkes_length_567, signtx_iface_error_handler, ((camkes_error_t){
        .type = CE_BUFFER_LENGTH_EXCEEDED,
        .instance = "crypto",
        .interface = "signtx_iface",
        .description = "buffer exceeded while marshalling print_mod in print_mod",
        .current_length = _camkes_length_567,
        .target_length = _camkes_length_567 + sizeof(_camkes_method_index_566),
        }), ({
            return UINT_MAX;
    }));

            memcpy(_camkes_buffer_base_568, & _camkes_method_index_566, sizeof(_camkes_method_index_566));
            _camkes_length_567 += sizeof(_camkes_method_index_566);
        

        /* Marshal the parameters. */
        
            
            _camkes_length_567 = print_mod_marshal_inputs_text(_camkes_length_567,
            
            text
            );
            if (unlikely(_camkes_length_567 == UINT_MAX)) {
                return UINT_MAX;
            }
        
            
            _camkes_length_567 = print_mod_marshal_inputs_source(_camkes_length_567,
            
            source
            );
            if (unlikely(_camkes_length_567 == UINT_MAX)) {
                return UINT_MAX;
            }
        
            
            _camkes_length_567 = print_mod_marshal_inputs_id(_camkes_length_567,
            
            id
            );
            if (unlikely(_camkes_length_567 == UINT_MAX)) {
                return UINT_MAX;
            }
        
            
            _camkes_length_567 = print_mod_marshal_inputs_isValid(_camkes_length_567,
            
            isValid
            );
            if (unlikely(_camkes_length_567 == UINT_MAX)) {
                return UINT_MAX;
            }
        

        assert(_camkes_length_567 <= (seL4_MsgMaxLength * sizeof(seL4_Word)) &&
            "uncaught buffer overflow while marshalling inputs for print_mod");

        return _camkes_length_567;
    }




    
    
    
    
    
    
    
    
    
    
    

    
    
    

    static int
    print_mod_unmarshal_outputs(
    
    unsigned _camkes_size_570
    
    
    

    
    

    ) {

        
        unsigned _camkes_length_572 UNUSED = 0;

        
        void * _camkes_buffer_base_573 UNUSED = (void*)(((void*)&seL4_GetIPCBuffer()->msg[0]));

        

        /* Unmarshal the parameters. */
        

        
        ERR_IF(ROUND_UP_UNSAFE(_camkes_length_572, sizeof(seL4_Word)) != _camkes_size_570, signtx_iface_error_handler, ((camkes_error_t){
            .type = CE_MALFORMED_RPC_PAYLOAD,
            .instance = "crypto",
            .interface = "signtx_iface",
            .description = "excess trailing bytes after unmarshalling parameters for print_mod",
            .length = _camkes_size_570,
            .current_index = _camkes_length_572,
            }), ({
                
                
                return -1;
        }));
    

    return 0;
    }






    void

signtx_iface_print_mod(

    
        
        
    
        
            const char *
        
        text
    

        
            ,
        
    
        
        
    
        
            const char *
        
        source
    

        
            ,
        
    
        
        
    
        
            int
        
        id
    

        
            ,
        
    
        
        
    
        
            int
        
        isValid
    

        
    

) {

    

    
    /* Save any pending reply cap as we'll eventually call seL4_Call which
     * could overwrite it. Note that we do this here before marshalling
     * parameters to ensure we don't inadvertently overwrite any marshalled
     * data with this call.
     */
    
        camkes_protect_reply_cap();
    
    


    
    
    

    /* Marshal all the parameters */
    
    unsigned _camkes_length_577 = 
    
    
    

    print_mod_marshal_inputs(
    
        
        text
        
            ,
        
    
        
        source
        
            ,
        
    
        
        id
        
            ,
        
    
        
        isValid
        
    
    )
;
    if (unlikely(_camkes_length_577 == UINT_MAX)) {
        /* Error in marshalling; bail out. */
        
            return;
        
    }

    
    unsigned _camkes_size_578;
    
    /* Call the endpoint */
    
    seL4_MessageInfo_t _camkes_info_579 = seL4_MessageInfo_new(0, 0, 0,
        
                ROUND_UP_UNSAFE(_camkes_length_577, sizeof(seL4_Word)) / sizeof(seL4_Word)
        
        );
    _camkes_info_579 = seL4_Call(14, _camkes_info_579);

    _camkes_size_578 =
    
        seL4_MessageInfo_get_length(_camkes_info_579) * sizeof(seL4_Word);
        assert(_camkes_size_578 <= seL4_MsgMaxLength * sizeof(seL4_Word));
    


    /* Unmarshal the response */
    
    int _camkes_error_580 = 
    
    
    
    
    

    print_mod_unmarshal_outputs(
    _camkes_size_578
    
    
    
    )
;
    if (unlikely(_camkes_error_580 != 0)) {
        /* Error in unmarshalling; bail out. */
        
            return;
        
    }

    
    


    
}