open Ctypes
open Unsigned
open View

open Fuse

module type LINUX_7_8 = sig
  include module type of In_common
  include module type of In_linux_7_8
end
  with module Hdr = In_common.Hdr
  and module Init = In_common.Init
  and module Forget = In_common.Forget
  and module Read = In_common.Read
  and module Release = In_common.Release
  and module Open = In_common.Open
  and module Rename = In_common.Rename
  and module Write = In_common.Write
  and module Flush = In_common.Flush
  and module Link = In_common.Link
  and module Access = In_common.Access
  and module Create = In_common.Create
  and module Mknod = In_common.Mknod
  and module Fsync = In_common.Fsync
  and module Mkdir = In_common.Mkdir
  and module Lk = In_common.Lk
  and module Interrupt = In_common.Interrupt
  and module Bmap = In_common.Bmap

module type OSX_7_8 = sig
  include module type of In_common
  include module type of In_osx_7_8
end
  with module Hdr = In_common.Hdr
  and module Init = In_common.Init
  and module Forget = In_common.Forget
  and module Read = In_common.Read
  and module Release = In_common.Release
  and module Open = In_common.Open
  and module Rename = In_common.Rename
  and module Write = In_common.Write
  and module Flush = In_common.Flush
  and module Link = In_common.Link
  and module Access = In_common.Access
  and module Create = In_common.Create
  and module Mknod = In_common.Mknod
  and module Fsync = In_common.Fsync
  and module Mkdir = In_common.Mkdir
  and module Lk = In_common.Lk
  and module Interrupt = In_common.Interrupt
  and module Bmap = In_common.Bmap

module Linux_7_8 : LINUX_7_8 = struct
  include In_common
  include In_linux_7_8
end

module Osx_7_8 : OSX_7_8 = struct
  include In_common
  include In_osx_7_8
end

module Linux_7_8_of_osx_7_8 : LINUX_7_8 = struct
  include Linux_7_8

  let linux_getxattr_of_osx_getxattr cons g req =
    let pkt = Getxattr.create_from_hdr
      ~size:(getf g Osx_7_8.Getxattr.size) req.hdr in
    let p = CArray.start pkt in
    let hdr = !@ (coerce (ptr char) (ptr Hdr.t) (p -@ sizeof Hdr.t)) in
    let g = !@ (coerce (ptr char) (ptr Getxattr.t) p) in
    {req with hdr; pkt = Getxattr g}    

  let read chan () =
    let module O = Osx_7_8 in
    let req = O.read chan () in
    match req.pkt with
    | O.Init i -> {req with pkt = Init i}
    | O.Getattr -> {req with pkt = Getattr}
    | O.Lookup s -> {req with pkt = Lookup s}
    | O.Opendir o -> {req with pkt = Opendir o}
    | O.Readdir r -> {req with pkt = Readdir r}
    | O.Releasedir r -> {req with pkt = Releasedir r}
    | O.Fsyncdir f -> {req with pkt = Fsyncdir f}
    | O.Rmdir r -> {req with pkt = Rmdir r}
    | O.Mkdir (m,name) -> {req with pkt = Mkdir (m,name)}
    | O.Getxattr g ->
      linux_getxattr_of_osx_getxattr (fun g -> Getxattr g) g req
    | O.Setxattr s ->
      let pkt = Setxattr.create_from_hdr
        ~size:(getf s O.Setxattr.size)
        ~flags:(getf s O.Setxattr.flags)
        req.hdr in
      let p = CArray.start pkt in
      let hdr = !@ (coerce (ptr char) (ptr Hdr.t) (p -@ sizeof Hdr.t)) in
      let s = !@ (coerce (ptr char) (ptr Setxattr.t) p) in
      {req with hdr; pkt = Setxattr s}
    | O.Listxattr l ->
      linux_getxattr_of_osx_getxattr (fun g -> Listxattr g) l req
    | O.Removexattr r -> {req with pkt = Removexattr r}
    | O.Access a -> {req with pkt = Access a}
    | O.Forget f -> {req with pkt = Forget f}
    | O.Readlink -> {req with pkt = Readlink}
    | O.Link (l,name) -> {req with pkt = Link (l,name)}
    | O.Symlink (name, target) -> {req with pkt = Symlink (name, target)}
    | O.Rename (r,src,dest) -> {req with pkt = Rename (r, src, dest)}
    | O.Open o -> {req with pkt = Open o}
    | O.Read r -> {req with pkt = Read r}
    | O.Write w -> {req with pkt = Write w}
    | O.Statfs -> {req with pkt = Statfs}
    | O.Flush f -> {req with pkt = Flush f}
    | O.Release r -> {req with pkt = Release r}
    | O.Fsync f -> {req with pkt = Fsync f}
    | O.Unlink u -> {req with pkt = Unlink u}
    | O.Create (c,name) ->
      {req with pkt = Create (c,name)} (* TODO: exists on OS X FUSE 7.8? *)
    | O.Mknod (m,name) -> {req with pkt = Mknod (m,name)}
    | O.Setattr s ->
      let pkt = Setattr.create_from_hdr
        ~valid:(getf s O.Setattr.valid)
        ~fh:(getf s O.Setattr.fh)
        ~size:(getf s O.Setattr.size)
        ~atime:(getf s O.Setattr.atime)
        ~mtime:(getf s O.Setattr.mtime)
        ~atimensec:(getf s O.Setattr.atimensec)
        ~mtimensec:(getf s O.Setattr.mtimensec)
        ~mode:(getf s O.Setattr.mode)
        ~uid:(getf s O.Setattr.uid)
        ~gid:(getf s O.Setattr.gid)
        req.hdr in
      let p = CArray.start pkt in
      let hdr = !@ (coerce (ptr char) (ptr Hdr.t) (p -@ sizeof Hdr.t)) in
      let s = !@ (coerce (ptr char) (ptr Setattr.t) p) in
      {req with hdr; pkt = Setattr s}
    | O.Getlk l -> {req with pkt = Getlk l}
    | O.Setlk l -> {req with pkt = Setlk l}
    | O.Setlkw l -> {req with pkt = Setlkw l}
    | O.Interrupt i -> {req with pkt = Interrupt i}
    | O.Bmap b -> {req with pkt = Bmap b}
    | O.Destroy -> {req with pkt = Destroy}
    | O.Setvolname _ -> {req with pkt = Other Opcode.FUSE_SETVOLNAME}
    | O.Getxtimes -> {req with pkt = Other Opcode.FUSE_GETXTIMES}
    | O.Exchange _ -> {req with pkt = Other Opcode.FUSE_EXCHANGE}
    | O.Other o -> {req with pkt = Other o}
end

module Osx_7_8_of_linux_7_8 : OSX_7_8 = struct
  include Osx_7_8

  let osx_getxattr_of_linux_getxattr cons g req =
    let pkt = Getxattr.create_from_hdr
      ~size:(getf g Linux_7_8.Getxattr.size)
      ~position:0l (* TODO: right meaning? *)
      req.hdr in
    let p = CArray.start pkt in
    let hdr = !@ (coerce (ptr char) (ptr Hdr.t) (p -@ sizeof Hdr.t)) in
    let g = !@ (coerce (ptr char) (ptr Getxattr.t) p) in
    {req with hdr; pkt = cons g}

  let read chan () =
    let module L = Linux_7_8 in
    let req = L.read chan () in
    match req.pkt with
    | L.Init i -> {req with pkt = Init i}
    | L.Getattr -> {req with pkt = Getattr}
    | L.Lookup s -> {req with pkt = Lookup s}
    | L.Opendir o -> {req with pkt = Opendir o}
    | L.Readdir r -> {req with pkt = Readdir r}
    | L.Releasedir r -> {req with pkt = Releasedir r}
    | L.Fsyncdir f -> {req with pkt = Fsyncdir f}
    | L.Rmdir r -> {req with pkt = Rmdir r}
    | L.Mkdir (m,name) -> {req with pkt = Mkdir (m,name)}
    | L.Getxattr g ->
      osx_getxattr_of_linux_getxattr (fun g -> Getxattr g) g req
    | L.Setxattr s ->
      let pkt = Setxattr.create_from_hdr
        ~size:(getf s L.Setxattr.size)
        ~flags:(getf s L.Setxattr.flags)
        ~position:0l (* TODO: right meaning? *)
        req.hdr in
      let p = CArray.start pkt in
      let hdr = !@ (coerce (ptr char) (ptr Hdr.t) (p -@ sizeof Hdr.t)) in
      let s = !@ (coerce (ptr char) (ptr Setxattr.t) p) in
      {req with hdr; pkt = Setxattr s}
    | L.Listxattr l ->
      osx_getxattr_of_linux_getxattr (fun g -> Listxattr g) l req
    | L.Removexattr r -> {req with pkt = Removexattr r}
    | L.Access a -> {req with pkt = Access a}
    | L.Forget f -> {req with pkt = Forget f}
    | L.Readlink -> {req with pkt = Readlink}
    | L.Link (l,name) -> {req with pkt = Link (l,name)}
    | L.Symlink (name,target) -> {req with pkt = Symlink (name, target)}
    | L.Rename (r,src,dest) -> {req with pkt = Rename (r,src,dest)}
    | L.Open o -> {req with pkt = Open o}
    | L.Read r -> {req with pkt = Read r}
    | L.Write w -> {req with pkt = Write w}
    | L.Statfs -> {req with pkt = Statfs}
    | L.Flush f -> {req with pkt = Flush f}
    | L.Release r -> {req with pkt = Release r}
    | L.Fsync f -> {req with pkt = Fsync f}
    | L.Unlink u -> {req with pkt = Unlink u}
    | L.Create (c,name) ->
      {req with pkt = Create (c,name)} (* TODO: exists on OS X FUSE 7.8? *)
    | L.Mknod (m,name) -> {req with pkt = Mknod (m,name)}
    | L.Setattr s ->
      let pkt = Setattr.create_from_hdr
        ~valid:(getf s L.Setattr.valid)
        ~fh:(getf s L.Setattr.fh)
        ~size:(getf s L.Setattr.size)
        ~atime:(getf s L.Setattr.atime)
        ~mtime:(getf s L.Setattr.mtime)
        ~atimensec:(getf s L.Setattr.atimensec)
        ~mtimensec:(getf s L.Setattr.mtimensec)
        ~mode:(getf s L.Setattr.mode)
        ~uid:(getf s L.Setattr.uid)
        ~gid:(getf s L.Setattr.gid)
        ~bkuptime:0L (* TODO: right meaning? *)
        ~chgtime:0L (* TODO: right meaning? *)
        ~crtime:0L (* TODO: right meaning? *)
        ~bkuptimensec:0l (* TODO: right meaning? *)
        ~chgtimensec:0l (* TODO: right meaning? *)
        ~crtimensec:0l (* TODO: right meaning? *)
        ~flags:0l (* TODO: right meaning? *)
        req.hdr in
      let p = CArray.start pkt in
      let hdr = !@ (coerce (ptr char) (ptr Hdr.t) (p -@ sizeof Hdr.t)) in
      let s = !@ (coerce (ptr char) (ptr Setattr.t) p) in
      {req with hdr; pkt = Setattr s}
    | L.Getlk l -> {req with pkt = Getlk l}
    | L.Setlk l -> {req with pkt = Setlk l}
    | L.Setlkw l -> {req with pkt = Setlkw l}
    | L.Interrupt i -> {req with pkt = Interrupt i}
    | L.Bmap b -> {req with pkt = Bmap b}
    | L.Destroy -> {req with pkt = Destroy}
    | L.Other o -> {req with pkt = Other o}

end
