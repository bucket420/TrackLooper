#ifndef HeterogeneousCore_AlpakaInterface_interface_devices_h
#define HeterogeneousCore_AlpakaInterface_interface_devices_h

#include <cassert>
#include <vector>

#include <alpaka/alpaka.hpp>

#include "config.h"
#include "traits.h"

namespace lst::alpakatools {

  namespace detail {

    template <typename TPlatform, typename = std::enable_if_t<is_platform_v<TPlatform>>>
    inline std::vector<alpaka::Dev<TPlatform>> enumerate_devices() {
      using Platform = TPlatform;
      using Device = alpaka::Dev<Platform>;

      std::vector<Device> devices;
      uint32_t n = alpaka::getDevCount<Platform>();
      devices.reserve(n);
      for (uint32_t i = 0; i < n; ++i) {
        devices.push_back(alpaka::getDevByIdx<Platform>(i));
        assert(alpaka::getNativeHandle(devices.back()) == static_cast<int>(i));
      }

      return devices;
    }

  }  // namespace detail

  // return the alpaka accelerator devices for the given platform
  template <typename TPlatform, typename = std::enable_if_t<is_platform_v<TPlatform>>>
  inline std::vector<alpaka::Dev<TPlatform>> const& devices() {
    static const auto devices = detail::enumerate_devices<TPlatform>();
    return devices;
  }

}  // namespace lst::alpakatools

#endif  // HeterogeneousCore_AlpakaInterface_interface_devices_h