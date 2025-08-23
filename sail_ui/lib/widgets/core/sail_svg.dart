import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sail_ui/sail_ui.dart';

enum SailSVGAsset {
  tabPeg,
  tabBMM,
  tabWithdrawalExplorer,

  tabSidechainSend,

  tabZSideMeltCast,
  tabZSideShieldDeshield,
  tabZSideOperationStatuses,

  tabConsole,
  tabSettings,
  tabTools,
  tabStarters,

  layerTwoLabsLogo,

  iconCalendar,
  iconQuestion,
  iconSearch,
  iconCopy,
  iconRestart,
  iconArrow,
  iconArrowForward,
  iconClose,
  iconGlobe,
  iconExpand,
  iconDropdown,
  iconDeposit,
  iconWithdraw,
  iconFormat,
  iconMelt,
  iconCast,
  iconTerminal,
  iconNetwork,
  iconPeers,
  iconPen,
  iconCheck,
  iconNewWindow,
  iconTools,

  iconHome,
  iconSend,
  iconReceive,
  iconTransactions,
  iconSidechains,
  iconLearn,

  iconSuccess,
  iconPending,
  iconPendingHalf,
  iconFailed,
  iconInfo,
  iconSelected,
  iconCoins,
  iconConnectionStatus,
  iconWarning,
  iconWallet,
  iconCoinnews,
  iconDelete,
  iconMultisig,
  iconBitdrive,
  iconHDWallet,

  lightMode,
  darkMode,
  lightDarkMode,

  meltCastDiagram,

  dividerDot,

  telegram,
  handHelping,
  iconShield,
  underline,
  filePlus2,
  sigma,
  iconMainchain,
  clock9,
  triangleAlert,
  triangle,
  hand,
  search,
  signpostBig,
  volume2,
  handHeart,
  barChartBig,
  contact,
  beerOff,
  sendHorizontal,
  moveDown,
  clipboardPlus,
  gamepad2,
  lectern,
  lasso,
  eraser,
  disc2,
  receipt,
  bedSingle,
  wine,
  briefcaseMedical,
  iceCreamBowl,
  parkingMeter,
  fileSearch,
  arrowDown,
  figma,
  cornerRightUp,
  fileKey,
  earth,
  chevronsRight,
  beef,
  flashlight,
  filePen,
  ghost,
  list,
  bicepsFlexed,
  cctv,
  textCursorInput,
  megaphone,
  croissant,
  toyBrick,
  pencilOff,
  routeOff,
  messageCircleQuestion,
  squareArrowRight,
  briefcaseBusiness,
  swissFranc,
  navigation2Off,
  bluetoothOff,
  bed,
  panelRightClose,
  signalLow,
  chevronsDown,
  memoryStick,
  disc3,
  wind,
  cornerUpRight,
  clapperboard,
  subscript,
  fileDigit,
  arrowBigDownDash,
  grape,
  flipVertical,
  hdmiPort,
  target,
  userCog,
  scissors,
  minimize2,
  cog,
  waypoints,
  megaphoneOff,
  receiptPoundSterling,
  crosshair,
  alignVerticalDistributeEnd,
  pi,
  tableCellsMerge,
  squareEqual,
  fileSliders,
  packageOpen,
  vegan,
  airplay,
  galleryThumbnails,
  clock8,
  section,
  messageCircleWarning,
  badgeEuro,
  repeat,
  circleUserRound,
  squareChevronRight,
  arrowRightLeft,
  grip,
  luggage,
  hourglass,
  fileBarChart,
  russianRuble,
  circleChevronRight,
  microwave,
  volume1,
  partyPopper,
  boxes,
  fileHeart,
  reply,
  badgePercent,
  squareDashedKanban,
  sunrise,
  toggleRight,
  bugOff,
  messageSquareShare,
  beer,
  pointer,
  receiptIndianRupee,
  sheet,
  sprayCan,
  scanLine,
  circleCheckBig,
  unfoldVertical,
  gitPullRequestDraft,
  layoutList,
  umbrella,
  user,
  listStart,
  scatterChart,
  lassoSelect,
  arrowBigDown,
  iterationCw,
  fullscreen,
  messageCircleHeart,
  sunDim,
  iconOpenInNew,
  replaceAll,
  squareArrowOutDownLeft,
  cannabis,
  iterationCcw,
  messageCircleMore,
  fileMinus,
  squarePower,
  squareChevronUp,
  alignHorizontalJustifyStart,
  copyPlus,
  timerOff,
  folderCheck,
  badgeJapaneseYen,
  arrowUpFromLine,
  flipVertical2,
  annoyed,
  ligature,
  messageSquareWarning,
  layoutGrid,
  rockingChair,
  chevronsUpDown,
  badgeMinus,
  calendarOff,
  circle,
  airVent,
  phoneMissed,
  scale3d,
  cornerLeftUp,
  milk,
  clipboardPen,
  home,
  fileUp,
  copyright,
  pictureInPicture,
  vault,
  circlePower,
  mailbox,
  gitlab,
  music,
  fileBarChart2,
  rectangleEllipsis,
  smartphone,
  fileSymlink,
  alarmClockCheck,
  candyOff,
  circuitBoard,
  folderTree,
  equal,
  recycle,
  arrowUpLeft,
  clipboardType,
  library,
  panelTopClose,
  filePieChart,
  squareArrowDown,
  listPlus,
  chevronDown,
  backpack,
  calendarCheck2,
  heading,
  hexagon,
  strikethrough,
  calendarFold,
  messageSquareHeart,
  bird,
  botMessageSquare,
  sunMedium,
  badgeInfo,
  shieldPlus,
  bookMarked,
  creativeCommons,
  shirt,
  dock,
  signpost,
  doorClosed,
  github,
  foldHorizontal,
  nfc,
  clipboardPaste,
  cone,
  cookingPot,
  proportions,
  bringToFront,
  usb,
  separatorVertical,
  boxSelect,
  hardHat,
  cakeSlice,
  sunMoon,
  ticket,
  calendarPlus2,
  caseLower,
  layoutTemplate,
  panelRightOpen,
  brackets,
  starOff,
  shrink,
  church,
  circlePercent,
  crop,
  flaskRound,
  cookie,
  redo2,
  circleSlash2,
  tag,
  bookCheck,
  iconTabShieldDeshield,
  octagonPause,
  cupSoda,
  option,
  sparkle,
  briefcase,
  circleChevronDown,
  presentation,
  squareSigma,
  rotateCw,
  fileAudio,
  ellipsisVertical,
  badgePlus,
  screenShareOff,
  squarePlay,
  alignHorizontalDistributeEnd,
  fileClock,
  calendarSearch,
  imageDown,
  swatchBook,
  radius,
  folderSync,
  panelsTopLeft,
  headset,
  circleEqual,
  dessert,
  carrot,
  receiptEuro,
  map,
  checkCheck,
  inbox,
  circleAlert,
  tvMinimal,
  alignJustify,
  power,
  aLargeSmall,
  tentTree,
  database,
  captions,
  martini,
  arrowUpToLine,
  monitorDown,
  badgeIndianRupee,
  cameraOff,
  fuel,
  satelliteDish,
  bike,
  swords,
  messageSquareOff,
  scanText,
  arrowDownZA,
  rat,
  tornado,
  toggleLeft,
  file,
  puzzle,
  alignVerticalDistributeCenter,
  signal,
  eggOff,
  arrowUp10,
  fileAudio2,
  baseline,
  vibrateOff,
  glassWater,
  brain,
  files,
  torus,
  scanSearch,
  squareDashedBottomCode,
  messageCircle,
  messageSquareDot,
  receiptJapaneseYen,
  voicemail,
  messagesSquare,
  shipWheel,
  messageSquareQuote,
  contrast,
  cuboid,
  alarmClockPlus,
  monitorPause,
  fileVideo2,
  archiveX,
  terminal,
  moveDiagonal,
  fileScan,
  arrowUpWideNarrow,
  move,
  maximize,
  betweenVerticalStart,
  laptopMinimal,
  radar,
  sparkles,
  lockKeyhole,
  octagonX,
  folderRoot,
  chevronUp,
  circleHelp,
  squarePercent,
  haze,
  folderOutput,
  folderSymlink,
  fileBadge2,
  vibrate,
  laugh,
  scanEye,
  spade,
  cloudRainWind,
  slidersVertical,
  undo2,
  fileVideo,
  stepBack,
  flaskConicalOff,
  arrowDownLeft,
  fileText,
  fileStack,
  folderOpen,
  packageMinus,
  droplet,
  wholeWord,
  paintRoller,
  zapOff,
  squareKanban,
  keyboard,
  x,
  chevronsRightLeft,
  joystick,
  cigarette,
  bath,
  barChart,
  qrCode,
  dot,
  iceCreamCone,
  languages,
  ampersands,
  arrowLeftFromLine,
  bellMinus,
  fileCog,
  wheat,
  cableCar,
  arrowUpNarrowWide,
  lock,
  dice2,
  logIn,
  squircle,
  cloudUpload,
  shieldEllipsis,
  ban,
  smartphoneNfc,
  listVideo,
  textSelect,
  shoppingBag,
  divide,
  piggyBank,
  batteryWarning,
  walletMinimal,
  circleDollarSign,
  milkOff,
  squareParking,
  refreshCcwDot,
  tally2,
  shell,
  repeat2,
  pilcrow,
  circleDotDashed,
  mailQuestion,
  cloudDrizzle,
  copyMinus,
  spline,
  refreshCw,
  pen,
  plane,
  alignVerticalSpaceBetween,
  chevronRight,
  tally3,
  clipboard,
  equalNot,
  package,
  instagram,
  mailWarning,
  euro,
  link,
  squareChevronLeft,
  globeLock,
  dice3,
  handPlatter,
  videoOff,
  userRoundPlus,
  key,
  squareActivity,
  shrub,
  sailboat,
  fileX2,
  squareSlash,
  brainCog,
  meh,
  slidersHorizontal,
  doorOpen,
  cornerDownRight,
  beaker,
  listTodo,
  cloudSun,
  iconDownload,
  arrowRight,
  store,
  antenna,
  chevronFirst,
  wheatOff,
  aperture,
  calendarPlus,
  brush,
  thermometerSnowflake,
  clover,
  conciergeBell,
  logOut,
  unfoldHorizontal,
  fileSpreadsheet,
  squareRadical,
  circlePlay,
  squareArrowUp,
  fileCode2,
  telescope,
  ship,
  earOff,
  worm,
  wallpaper,
  ambulance,
  space,
  fileInput,
  barChart2,
  bookDashed,
  stretchVertical,
  calendarCheck,
  diff,
  showerHead,
  squarePen,
  arrowDownUp,
  gitPullRequest,
  minimize,
  group,
  settings,
  cloudSnow,
  notepadTextDashed,
  calendarX2,
  cassetteTape,
  thumbsDown,
  dice1,
  moveDownLeft,
  vote,
  botOff,
  type,
  squareDashedMousePointer,
  squareMenu,
  mousePointerClick,
  regex,
  squareCheckBig,
  loaderCircle,
  popsicle,
  lampFloor,
  utensils,
  archive,
  bean,
  panelsRightBottom,
  messageSquareText,
  refreshCwOff,
  phoneOutgoing,
  tally1,
  arrowUpFromDot,
  candy,
  pocket,
  repeat1,
  magnet,
  circleParking,
  mail,
  school,
  arrowBigRight,
  shield,
  download,
  kanban,
  fileVolume,
  expand,
  galleryVerticalEnd,
  fileWarning,
  discAlbum,
  pin,
  arrowUpAZ,
  squareCheck,
  barChartHorizontalBig,
  import,
  webcam,
  phoneForwarded,
  bellPlus,
  squareDot,
  cornerRightDown,
  squareDivide,
  bookOpen,
  forklift,
  calendarCog,
  castle,
  areaChart,
  orbit,
  parentheses,
  projector,
  pilcrowRight,
  server,
  userRoundCheck,
  bolt,
  tv,
  messageSquareDashed,
  droplets,
  skipForward,
  archiveRestore,
  volume,
  lampWallUp,
  barChart3,
  drumstick,
  userPlus,
  batteryMedium,
  bookA,
  batteryCharging,
  shapes,
  folders,
  satellite,
  listMinus,
  circleArrowLeft,
  bookmarkMinus,
  heater,
  layers,
  earthLock,
  squareParkingOff,
  dna,
  mouseOff,
  fileCheck2,
  slash,
  radio,
  alignCenterVertical,
  alarmClock,
  alarmClockOff,
  book,
  keyboardMusic,
  hotel,
  bookText,
  variable,
  touchpadOff,
  bitcoin,
  messageSquareX,
  carFront,
  alarmSmoke,
  dice4,
  skull,
  mailMinus,
  bot,
  plug,
  shieldX,
  trainTrack,
  goal,
  folderArchive,
  signalHigh,
  userMinus,
  planeLanding,
  wallet,
  circleCheck,
  tally4,
  fileImage,
  squareDashedBottom,
  panelTopOpen,
  bell,
  gitBranch,
  squareM,
  coffee,
  panelLeftDashed,
  code,
  railSymbol,
  circleDivide,
  cake,
  spellCheck2,
  settings2,
  tally5,
  messageCircleDashed,
  cloudMoonRain,
  radioTower,
  thermometer,
  cast,
  milestone,
  move3d,
  flag,
  podcast,
  tvMinimalPlay,
  gitFork,
  eyeOff,
  dice5,
  tramFront,
  battery,
  blinds,
  arrowLeftToLine,
  newspaper,
  clipboardPenLine,
  snowflake,
  disc,
  stepForward,
  bomb,
  piano,
  bookCopy,
  arrowUp01,
  databaseZap,
  rotate3d,
  starHalf,
  switchCamera,
  imagePlus,
  pencilRuler,
  container,
  ruler,
  turtle,
  frown,
  treePine,
  audioLines,
  circleSlash,
  notebookText,
  layoutDashboard,
  fileLineChart,
  cpu,
  alignEndHorizontal,
  flameKindling,
  clipboardList,
  biohazard,
  barChart4,
  folderX,
  bookOpenCheck,
  listOrdered,
  factory,
  bold,
  tablets,
  fence,
  trophy,
  hash,
  shieldMinus,
  link2Off,
  share2,
  batteryFull,
  plus,
  monitorStop,
  panelBottom,
  clipboardMinus,
  check,
  alignVerticalJustifyEnd,
  rabbit,
  plugZap,
  nut,
  mailPlus,
  moveDownRight,
  rotateCcw,
  heartCrack,
  flipHorizontal2,
  hardDrive,
  betweenHorizontalEnd,
  tent,
  hardDriveDownload,
  circleFadingPlus,
  penLine,
  alignVerticalSpaceAround,
  hospital,
  caseSensitive,
  focus,
  bluetooth,
  alignEndVertical,
  pieChart,
  squareSplitVertical,
  headphones,
  tableProperties,
  gitPullRequestCreateArrow,
  folderGit2,
  squareX,
  squareAsterisk,
  rss,
  tableCellsSplit,
  flower2,
  landmark,
  wifi,
  cornerUpLeft,
  fileArchive,
  squareArrowUpLeft,
  arrowDownFromLine,
  watch,
  squareArrowDownRight,
  scale,
  dice6,
  messageSquareMore,
  ampersand,
  dnaOff,
  squareArrowOutUpRight,
  handCoins,
  rollerCoaster,
  monitorSmartphone,
  gitCommitVertical,
  info,
  blocks,
  popcorn,
  fileBadge,
  badgeDollarSign,
  userX,
  navigationOff,
  keySquare,
  ticketMinus,
  dog,
  layoutPanelLeft,
  fan,
  radioReceiver,
  loader,
  palette,
  pilcrowLeft,
  diamondPlus,
  circleArrowOutDownLeft,
  receiptSwissFranc,
  package2,
  caseUpper,
  refreshCcw,
  cloudFog,
  iconArrowDown,
  gitBranchPlus,
  fileX,
  heading1,
  hop,
  folderUp,
  soup,
  folderPlus,
  badgeRussianRuble,
  gitMerge,
  japaneseYen,
  gripHorizontal,
  listX,
  shieldHalf,
  mic,
  venetianMask,
  rainbow,
  gitPullRequestArrow,
  copy,
  smilePlus,
  fish,
  moveUpLeft,
  listTree,
  zoomIn,
  circleChevronUp,
  circleArrowOutDownRight,
  squareGanttChart,
  searchCheck,
  arrowDownToLine,
  glasses,
  coins,
  alignStartVertical,
  arrowsUpFromLine,
  iconHdwallet,
  snail,
  libraryBig,
  bookmarkX,
  bookKey,
  panelLeft,
  testTubeDiagonal,
  origami,
  squareLibrary,
  messageCircleOff,
  squareUserRound,
  wandSparkles,
  fileType2,
  textQuote,
  caravan,
  badgeCent,
  panelTopDashed,
  notebookTabs,
  text,
  testTubes,
  fireExtinguisher,
  eggFried,
  flagTriangleLeft,
  alignRight,
  textCursor,
  image,
  panelBottomOpen,
  maximize2,
  iconTabSend,
  lightbulb,
  serverOff,
  arrowBigLeftDash,
  imagePlay,
  sunset,
  save,
  smile,
  searchCode,
  lamp,
  siren,
  images,
  scan,
  navigation,
  cloudLightning,
  iconDashboardTab,
  citrus,
  messageSquareDiff,
  bellElectric,
  ham,
  candlestickChart,
  monitorPlay,
  badgePoundSterling,
  hardDriveUpload,
  appWindow,
  badge,
  iconTabDepositWithdraw,
  theater,
  paperclip,
  heading2,
  squareScissors,
  fastForward,
  flagTriangleRight,
  calendarRange,
  contactRound,
  syringe,
  searchSlash,
  fileQuestion,
  barChartHorizontal,
  sticker,
  award,
  panelRightDashed,
  zoomOut,
  squareArrowOutUpLeft,
  box,
  thumbsUp,
  superscript,
  ticketPercent,
  batteryLow,
  touchpad,
  speech,
  percent,
  squareChevronDown,
  square,
  crown,
  bluetoothSearching,
  timerReset,
  stethoscope,
  iconSidechain,
  eclipse,
  donut,
  candyCane,
  play,
  folderHeart,
  penOff,
  fileCheck,
  leafyGreen,
  tangent,
  bookAudio,
  table,
  split,
  send,
  barcode,
  videotape,
  scroll,
  phoneCall,
  columns4,
  baggageClaim,
  circleArrowOutUpRight,
  radiation,
  speaker,
  userRoundSearch,
  undoDot,
  facebook,
  codesandbox,
  fileDown,
  badgeCheck,
  baby,
  smartphoneCharging,
  bookPlus,
  unplug,
  heading3,
  bluetoothConnected,
  camera,
  link2,
  printer,
  listCollapse,
  workflow,
  trees,
  panelLeftClose,
  gitGraph,
  redo,
  captionsOff,
  club,
  folderMinus,
  moveDiagonal2,
  combine,
  arrowUpRight,
  truck,
  layoutPanelTop,
  lifeBuoy,
  userSearch,
  squareUser,
  tableColumnsSplit,
  betweenHorizontalStart,
  pickaxe,
  packageX,
  penTool,
  alarmClockMinus,
  panelsLeftBottom,
  circleGauge,
  folderCog,
  atSign,
  rotateCcwSquare,
  circleArrowRight,
  shieldAlert,
  mapPinOff,
  listRestart,
  handMetal,
  egg,
  carTaxiFront,
  squareMousePointer,
  monitorX,
  squareTerminal,
  grid2x2Check,
  bus,
  filePenLine,
  bookHeart,
  infinity,
  gem,
  filterX,
  gitCompare,
  receiptCent,
  feather,
  webhookOff,
  trash,
  treePalm,
  arrowDown10,
  databaseBackup,
  armchair,
  wifiOff,
  userRound,
  ungroup,
  bookLock,
  leaf,
  arrowDownWideNarrow,
  network,
  fileLock2,
  appWindowMac,
  arrowUpZA,
  scanBarcode,
  cornerLeftDown,
  messageSquarePlus,
  folderClock,
  paintbrushVertical,
  dollarSign,
  triangleRight,
  indianRupee,
  construction,
  circlePlus,
  graduationCap,
  scanFace,
  fishSymbol,
  monitorSpeaker,
  guitar,
  star,
  lockKeyholeOpen,
  monitorCheck,
  sandwich,
  chefHat,
  heading6,
  cloudOff,
  saveAll,
  sun,
  wrench,
  signalMedium,
  grab,
  pyramid,
  bookMinus,
  gauge,
  messageSquare,
  bugPlay,
  bookX,
  heading4,
  pizza,
  unlink,
  chevronsDownUp,
  bone,
  flashlightOff,
  fileJson2,
  anchor,
  hammer,
  plug2,
  notebookPen,
  chevronsUp,
  columns3,
  moveHorizontal,
  highlighter,
  squareArrowUpRight,
  tabletSmartphone,
  circleStop,
  twitch,
  banana,
  treeDeciduous,
  folderLock,
  locate,
  listMusic,
  bug,
  panelTop,
  messageSquareCode,
  mailOpen,
  youtube,
  chevronsLeftRight,
  bookmarkPlus,
  aArrowUp,
  towerControl,
  bookUp,
  pocketKnife,
  shovel,
  compass,
  fileMinus2,
  alignHorizontalJustifyEnd,
  serverCrash,
  trafficCone,
  planeTakeoff,
  folderKanban,
  mailSearch,
  imageUp,
  cloudMoon,
  columns2,
  warehouse,
  rotateCwSquare,
  squareFunction,
  frame,
  creditCard,
  circleArrowDown,
  table2,
  fileKey2,
  copyleft,
  grid3x3,
  ticketX,
  alignVerticalJustifyStart,
  heartOff,
  cylinder,
  computer,
  bookType,
  pillBottle,
  heading5,
  thermometerSun,
  badgeHelp,
  locateOff,
  replyAll,
  pencil,
  cloudRain,
  sendToBack,
  iconTabOperationStatuses,
  gitPullRequestClosed,
  arrowBigRightDash,
  alignVerticalDistributeStart,
  bookDown,
  poundSterling,
  monitorUp,
  beanOff,
  trash2,
  circleUser,
  skipBack,
  filePlus,
  scrollText,
  ganttChart,
  diamond,
  delete,
  command,
  packageCheck,
  alignCenterHorizontal,
  clock,
  bellRing,
  removeFormatting,
  router,
  footprints,
  octagon,
  arrowBigLeft,
  tableRowsSplit,
  phone,
  circleX,
  landPlot,
  alignHorizontalJustifyCenter,
  sunSnow,
  imageOff,
  umbrellaOff,
  arrowDownAZ,
  panelLeftOpen,
  brainCircuit,
  moveVertical,
  usersRound,
  salad,
  dumbbell,
  tractor,
  waves,
  folderClosed,
  eye,
  userRoundCog,
  indentIncrease,
  mousePointerBan,
  badgeAlert,
  serverCog,
  pipette,
  phoneOff,
  flower,
  banknote,
  sprout,
  brickWall,
  copyCheck,
  rectangleVertical,
  pill,
  codepen,
  dribbble,
  messageCirclePlus,
  axe,
  squarePlus,
  gift,
  receiptRussianRuble,
  packagePlus,
  externalLink,
  lineChart,
  currency,
  wand,
  fileMusic,
  car,
  zap,
  trello,
  listChecks,
  messageSquareReply,
  badgeX,
  building2,
  moonStar,
  clock1,
  cigaretteOff,
  binary,
  chevronLast,
  pointerOff,
  mousePointer2,
  packageSearch,
  micOff,
  lampDesk,
  share,
  circleParkingOff,
  tags,
  squareBottomDashedScissors,
  iconTabBmm,
  album,
  keyRound,
  squareCode,
  folderSearch2,
  arrowUp,
  circleArrowOutUpLeft,
  microscope,
  testTube,
  bellOff,
  linkedin,
  arrowDownNarrowWide,
  clock3,
  panelRight,
  drum,
  view,
  music2,
  wrapText,
  gitCompareArrows,
  calendarMinus,
  bookImage,
  fileVolume2,
  userRoundX,
  undo,
  video,
  circleEllipsis,
  activity,
  pencilLine,
  personStanding,
  twitter,
  mapPin,
  folderInput,
  filter,
  lightbulbOff,
  phoneIncoming,
  refrigerator,
  italic,
  listEnd,
  handshake,
  chevronsLeft,
  rows2,
  mailX,
  medal,
  messageCircleCode,
  calendar,
  inspectionPanel,
  notepadText,
  messageCircleX,
  arrowRightFromLine,
  globe,
  arrowLeft,
  paintbrush,
  rows3,
  alignCenter,
  badgeSwissFranc,
  cross,
  squareMinus,
  university,
  route,
  circleArrowUp,
  diameter,
  pcCase,
  ellipsis,
  calendarHeart,
  bookHeadphones,
  arrowDownRight,
  fileBox,
  pawPrint,
  laptop,
  powerOff,
  redoDot,
  axis3d,
  arrowBigUp,
  framer,
  keyboardOff,
  mountain,
  stretchHorizontal,
  bellDot,
  clipboardX,
  folderDown,
  shieldQuestion,
  panelBottomDashed,
  volumeX,
  music3,
  copySlash,
  fileCode,
  moveLeft,
  slack,
  circleDashed,
  clock2,
  userRoundMinus,
  scissorsLineDashed,
  fileOutput,
  cloud,
  hopOff,
  clock11,
  shuffle,
  quote,
  anvil,
  washingMachine,
  gripVertical,
  clock6,
  drill,
  plugZap2,
  alignHorizontalDistributeStart,
  fileType,
  rewind,
  wineOff,
  upload,
  trendingDown,
  bookmarkCheck,
  foldVertical,
  calendarX,
  pause,
  radical,
  arrowBigUpDash,
  folderKey,
  grid2x2,
  cloudHail,
  searchX,
  cloudy,
  replace,
  forward,
  mountainSnow,
  indentDecrease,
  circleMinus,
  dices,
  blend,
  bookmark,
  braces,
  rocket,
  circleDot,
  moveRight,
  drama,
  asterisk,
  userCheck,
  calendarClock,
  fishOff,
  folderSearch,
  folderPen,
  cloudSunRain,
  gitPullRequestCreate,
  tablet,
  mailCheck,
  alignVerticalJustifyCenter,
  fileDiff,
  monitorDot,
  ticketSlash,
  alignHorizontalSpaceBetween,
  webhook,
  diamondPercent,
  folderOpenDot,
  arrowLeftRight,
  codeXml,
  cloudDownload,
  utilityPole,
  signalZero,
  bookUp2,
  monitorOff,
  ear,
  spellCheck,
  fileTerminal,
  flame,
  iconTabMeltCast,
  galleryHorizontalEnd,
  nutOff,
  component,
  circleOff,
  fileSearch2,
  alignStartHorizontal,
  locateFixed,
  lockOpen,
  loaderPinwheel,
  atom,
  cat,
  cloudCog,
  sword,
  squarePilcrow,
  squirrel,
  menu,
  pinOff,
  lampCeiling,
  folderDot,
  utensilsCrossed,
  ratio,
  squareArrowDownLeft,
  grid2x2X,
  octagonAlert,
  galleryVertical,
  imageMinus,
  clock7,
  arrowRightToLine,
  aArrowDown,
  merge,
  mapPinned,
  squarePi,
  alignHorizontalSpaceAround,
  chrome,
  stickyNote,
  ticketPlus,
  shoppingCart,
  copyX,
  calculator,
  clock10,
  trainFrontTunnel,
  clock12,
  apple,
  circleChevronLeft,
  mouse,
  flaskConical,
  pictureInPicture2,
  pentagon,
  diamondMinus,
  shieldCheck,
  arrowDown01,
  messageCircleReply,
  circlePause,
  mails,
  clock5,
  rectangleHorizontal,
  shoppingBasket,
  listFilter,
  receiptText,
  music4,
  bookUser,
  shieldBan,
  arrowDownToDot,
  building,
  clipboardCopy,
  angry,
  lollipop,
  betweenVerticalEnd,
  history,
  gavel,
  folder,
  draftingCompass,
  alignHorizontalDistributeCenter,
  fileLock,
  layers2,
  users,
  boomBox,
  slice,
  folderGit,
  fingerprint,
  flagOff,
  micVocal,
  cornerDownLeft,
  fileAxis3d,
  bookOpenText,
  timer,
  gamepad,
  gitCommitHorizontal,
  monitor,
  clipboardCheck,
  unlink2,
  squareArrowOutDownRight,
  minus,
  heartPulse,
  rows4,
  heartHandshake,
  bedDouble,
  textSearch,
  audioWaveform,
  navigation2,
  paintBucket,
  chevronLeft,
  moveUp,
  film,
  moon,
  squareArrowLeft,
  panelBottomClose,
  weight,
  shieldOff,
  layers3,
  scaling,
  cable,
  accessibility,
  moveUpRight,
  walletCards,
  busFront,
  lampWallDown,
  mousePointer,
  fileJson,
  trainFront,
  calendarMinus2,
  ribbon,
  squareStack,
  flipHorizontal,
  galleryHorizontal,
  notebook,
  stamp,
  squareSplitHorizontal,
  arrowUpDown,
  screenShare,
  calendarDays,
  alignLeft,
  separatorHorizontal,
  ferrisWheel,
  sofa,
  clock4,
  ticketCheck,
  cherry,
  heart,
  trendingUp,
}

enum SailPNGAsset {
  meltCastDiagram,
  articleBeginner,
}

/// If you don't want to overwrite the color of the svg, put it in here!
// useful for svgs that already have a color like red or blue, that are
// not supposed to be the same color of the text, or ones that have
// multiple colors
const coloredAssets = [
  SailSVGAsset.iconSuccess,
  SailSVGAsset.iconPending,
  SailSVGAsset.iconPendingHalf,
  SailSVGAsset.iconFailed,
  SailSVGAsset.iconInfo,
];

class SailSVG {
  static Widget icon(
    SailSVGAsset asset, {
    bool isHighlighted = false,
    double? width,
    double? height,
    Color? color,
  }) {
    return Builder(
      builder: (context) {
        final colors = SailTheme.of(context).colors;

        return SailSVG.fromAsset(
          asset,
          color: color ?? (coloredAssets.contains(asset) ? null : (isHighlighted ? colors.primary : colors.icon)),
          width: width ?? SailStyleValues.iconSizePrimary,
          height: height ?? SailStyleValues.iconSizePrimary,
        );
      },
    );
  }

  static SvgPicture fromAsset(
    SailSVGAsset asset, {
    double? height,
    double? width,
    Color? color,
  }) {
    return SvgPicture.asset(
      asset.toAssetPath(),
      package: 'sail_ui',
      width: width,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      height: height,
    );
  }

  static Widget png(
    SailPNGAsset asset, {
    double? width,
    double? height,
    BoxFit? fit,
  }) {
    return Image.asset(
      asset.toAssetPath(),
      package: 'sail_ui',
      width: width,
      height: height,
      fit: fit ?? BoxFit.contain,
    );
  }
}

extension AsAssetPath on SailSVGAsset {
  String toAssetPath() {
    switch (this) {
      case SailSVGAsset.telegram:
        return 'assets/svgs/telegram.svg';
      case SailSVGAsset.handHelping:
        return 'assets/svgs/hand-helping.svg';
      case SailSVGAsset.iconShield:
        return 'assets/svgs/icon_shield.svg';
      case SailSVGAsset.underline:
        return 'assets/svgs/underline.svg';
      case SailSVGAsset.filePlus2:
        return 'assets/svgs/file-plus-2.svg';
      case SailSVGAsset.sigma:
        return 'assets/svgs/sigma.svg';
      case SailSVGAsset.iconMainchain:
        return 'assets/svgs/icon_mainchain.svg';
      case SailSVGAsset.clock9:
        return 'assets/svgs/clock-9.svg';
      case SailSVGAsset.triangleAlert:
        return 'assets/svgs/triangle-alert.svg';
      case SailSVGAsset.triangle:
        return 'assets/svgs/triangle.svg';
      case SailSVGAsset.hand:
        return 'assets/svgs/hand.svg';
      case SailSVGAsset.search:
        return 'assets/svgs/search.svg';
      case SailSVGAsset.signpostBig:
        return 'assets/svgs/signpost-big.svg';
      case SailSVGAsset.volume2:
        return 'assets/svgs/volume-2.svg';
      case SailSVGAsset.handHeart:
        return 'assets/svgs/hand-heart.svg';
      case SailSVGAsset.barChartBig:
        return 'assets/svgs/bar-chart-big.svg';
      case SailSVGAsset.contact:
        return 'assets/svgs/contact.svg';
      case SailSVGAsset.beerOff:
        return 'assets/svgs/beer-off.svg';
      case SailSVGAsset.sendHorizontal:
        return 'assets/svgs/send-horizontal.svg';
      case SailSVGAsset.moveDown:
        return 'assets/svgs/move-down.svg';
      case SailSVGAsset.clipboardPlus:
        return 'assets/svgs/clipboard-plus.svg';
      case SailSVGAsset.gamepad2:
        return 'assets/svgs/gamepad-2.svg';
      case SailSVGAsset.lectern:
        return 'assets/svgs/lectern.svg';
      case SailSVGAsset.lasso:
        return 'assets/svgs/lasso.svg';
      case SailSVGAsset.eraser:
        return 'assets/svgs/eraser.svg';
      case SailSVGAsset.disc2:
        return 'assets/svgs/disc-2.svg';
      case SailSVGAsset.receipt:
        return 'assets/svgs/receipt.svg';
      case SailSVGAsset.bedSingle:
        return 'assets/svgs/bed-single.svg';
      case SailSVGAsset.wine:
        return 'assets/svgs/wine.svg';
      case SailSVGAsset.briefcaseMedical:
        return 'assets/svgs/briefcase-medical.svg';
      case SailSVGAsset.iceCreamBowl:
        return 'assets/svgs/ice-cream-bowl.svg';
      case SailSVGAsset.parkingMeter:
        return 'assets/svgs/parking-meter.svg';
      case SailSVGAsset.fileSearch:
        return 'assets/svgs/file-search.svg';
      case SailSVGAsset.arrowDown:
        return 'assets/svgs/arrow-down.svg';
      case SailSVGAsset.figma:
        return 'assets/svgs/figma.svg';
      case SailSVGAsset.cornerRightUp:
        return 'assets/svgs/corner-right-up.svg';
      case SailSVGAsset.fileKey:
        return 'assets/svgs/file-key.svg';
      case SailSVGAsset.earth:
        return 'assets/svgs/earth.svg';
      case SailSVGAsset.chevronsRight:
        return 'assets/svgs/chevrons-right.svg';
      case SailSVGAsset.beef:
        return 'assets/svgs/beef.svg';
      case SailSVGAsset.flashlight:
        return 'assets/svgs/flashlight.svg';
      case SailSVGAsset.filePen:
        return 'assets/svgs/file-pen.svg';
      case SailSVGAsset.ghost:
        return 'assets/svgs/ghost.svg';
      case SailSVGAsset.list:
        return 'assets/svgs/list.svg';
      case SailSVGAsset.bicepsFlexed:
        return 'assets/svgs/biceps-flexed.svg';
      case SailSVGAsset.cctv:
        return 'assets/svgs/cctv.svg';
      case SailSVGAsset.textCursorInput:
        return 'assets/svgs/text-cursor-input.svg';
      case SailSVGAsset.megaphone:
        return 'assets/svgs/megaphone.svg';
      case SailSVGAsset.croissant:
        return 'assets/svgs/croissant.svg';
      case SailSVGAsset.toyBrick:
        return 'assets/svgs/toy-brick.svg';
      case SailSVGAsset.pencilOff:
        return 'assets/svgs/pencil-off.svg';
      case SailSVGAsset.routeOff:
        return 'assets/svgs/route-off.svg';
      case SailSVGAsset.messageCircleQuestion:
        return 'assets/svgs/message-circle-question.svg';
      case SailSVGAsset.squareArrowRight:
        return 'assets/svgs/square-arrow-right.svg';
      case SailSVGAsset.briefcaseBusiness:
        return 'assets/svgs/briefcase-business.svg';
      case SailSVGAsset.swissFranc:
        return 'assets/svgs/swiss-franc.svg';
      case SailSVGAsset.navigation2Off:
        return 'assets/svgs/navigation-2-off.svg';
      case SailSVGAsset.bluetoothOff:
        return 'assets/svgs/bluetooth-off.svg';
      case SailSVGAsset.bed:
        return 'assets/svgs/bed.svg';
      case SailSVGAsset.panelRightClose:
        return 'assets/svgs/panel-right-close.svg';
      case SailSVGAsset.signalLow:
        return 'assets/svgs/signal-low.svg';
      case SailSVGAsset.chevronsDown:
        return 'assets/svgs/chevrons-down.svg';
      case SailSVGAsset.memoryStick:
        return 'assets/svgs/memory-stick.svg';
      case SailSVGAsset.disc3:
        return 'assets/svgs/disc-3.svg';
      case SailSVGAsset.wind:
        return 'assets/svgs/wind.svg';
      case SailSVGAsset.cornerUpRight:
        return 'assets/svgs/corner-up-right.svg';
      case SailSVGAsset.clapperboard:
        return 'assets/svgs/clapperboard.svg';
      case SailSVGAsset.subscript:
        return 'assets/svgs/subscript.svg';
      case SailSVGAsset.fileDigit:
        return 'assets/svgs/file-digit.svg';
      case SailSVGAsset.arrowBigDownDash:
        return 'assets/svgs/arrow-big-down-dash.svg';
      case SailSVGAsset.grape:
        return 'assets/svgs/grape.svg';
      case SailSVGAsset.flipVertical:
        return 'assets/svgs/flip-vertical.svg';
      case SailSVGAsset.hdmiPort:
        return 'assets/svgs/hdmi-port.svg';
      case SailSVGAsset.target:
        return 'assets/svgs/target.svg';
      case SailSVGAsset.userCog:
        return 'assets/svgs/user-cog.svg';
      case SailSVGAsset.scissors:
        return 'assets/svgs/scissors.svg';
      case SailSVGAsset.minimize2:
        return 'assets/svgs/minimize-2.svg';
      case SailSVGAsset.cog:
        return 'assets/svgs/cog.svg';
      case SailSVGAsset.waypoints:
        return 'assets/svgs/waypoints.svg';
      case SailSVGAsset.megaphoneOff:
        return 'assets/svgs/megaphone-off.svg';
      case SailSVGAsset.receiptPoundSterling:
        return 'assets/svgs/receipt-pound-sterling.svg';
      case SailSVGAsset.crosshair:
        return 'assets/svgs/crosshair.svg';
      case SailSVGAsset.alignVerticalDistributeEnd:
        return 'assets/svgs/align-vertical-distribute-end.svg';
      case SailSVGAsset.pi:
        return 'assets/svgs/pi.svg';
      case SailSVGAsset.tableCellsMerge:
        return 'assets/svgs/table-cells-merge.svg';
      case SailSVGAsset.squareEqual:
        return 'assets/svgs/square-equal.svg';
      case SailSVGAsset.fileSliders:
        return 'assets/svgs/file-sliders.svg';
      case SailSVGAsset.packageOpen:
        return 'assets/svgs/package-open.svg';
      case SailSVGAsset.vegan:
        return 'assets/svgs/vegan.svg';
      case SailSVGAsset.airplay:
        return 'assets/svgs/airplay.svg';
      case SailSVGAsset.galleryThumbnails:
        return 'assets/svgs/gallery-thumbnails.svg';
      case SailSVGAsset.clock8:
        return 'assets/svgs/clock-8.svg';
      case SailSVGAsset.section:
        return 'assets/svgs/section.svg';
      case SailSVGAsset.messageCircleWarning:
        return 'assets/svgs/message-circle-warning.svg';
      case SailSVGAsset.badgeEuro:
        return 'assets/svgs/badge-euro.svg';
      case SailSVGAsset.repeat:
        return 'assets/svgs/repeat.svg';
      case SailSVGAsset.circleUserRound:
        return 'assets/svgs/circle-user-round.svg';
      case SailSVGAsset.squareChevronRight:
        return 'assets/svgs/square-chevron-right.svg';
      case SailSVGAsset.arrowRightLeft:
        return 'assets/svgs/arrow-right-left.svg';
      case SailSVGAsset.grip:
        return 'assets/svgs/grip.svg';
      case SailSVGAsset.luggage:
        return 'assets/svgs/luggage.svg';
      case SailSVGAsset.hourglass:
        return 'assets/svgs/hourglass.svg';
      case SailSVGAsset.fileBarChart:
        return 'assets/svgs/file-bar-chart.svg';
      case SailSVGAsset.russianRuble:
        return 'assets/svgs/russian-ruble.svg';
      case SailSVGAsset.circleChevronRight:
        return 'assets/svgs/circle-chevron-right.svg';
      case SailSVGAsset.microwave:
        return 'assets/svgs/microwave.svg';
      case SailSVGAsset.volume1:
        return 'assets/svgs/volume-1.svg';
      case SailSVGAsset.partyPopper:
        return 'assets/svgs/party-popper.svg';
      case SailSVGAsset.boxes:
        return 'assets/svgs/boxes.svg';
      case SailSVGAsset.fileHeart:
        return 'assets/svgs/file-heart.svg';
      case SailSVGAsset.reply:
        return 'assets/svgs/reply.svg';
      case SailSVGAsset.badgePercent:
        return 'assets/svgs/badge-percent.svg';
      case SailSVGAsset.squareDashedKanban:
        return 'assets/svgs/square-dashed-kanban.svg';
      case SailSVGAsset.sunrise:
        return 'assets/svgs/sunrise.svg';
      case SailSVGAsset.toggleRight:
        return 'assets/svgs/toggle-right.svg';
      case SailSVGAsset.bugOff:
        return 'assets/svgs/bug-off.svg';
      case SailSVGAsset.messageSquareShare:
        return 'assets/svgs/message-square-share.svg';
      case SailSVGAsset.beer:
        return 'assets/svgs/beer.svg';
      case SailSVGAsset.pointer:
        return 'assets/svgs/pointer.svg';
      case SailSVGAsset.receiptIndianRupee:
        return 'assets/svgs/receipt-indian-rupee.svg';
      case SailSVGAsset.sheet:
        return 'assets/svgs/sheet.svg';
      case SailSVGAsset.sprayCan:
        return 'assets/svgs/spray-can.svg';
      case SailSVGAsset.scanLine:
        return 'assets/svgs/scan-line.svg';
      case SailSVGAsset.circleCheckBig:
        return 'assets/svgs/circle-check-big.svg';
      case SailSVGAsset.unfoldVertical:
        return 'assets/svgs/unfold-vertical.svg';
      case SailSVGAsset.gitPullRequestDraft:
        return 'assets/svgs/git-pull-request-draft.svg';
      case SailSVGAsset.layoutList:
        return 'assets/svgs/layout-list.svg';
      case SailSVGAsset.umbrella:
        return 'assets/svgs/umbrella.svg';
      case SailSVGAsset.user:
        return 'assets/svgs/user.svg';
      case SailSVGAsset.listStart:
        return 'assets/svgs/list-start.svg';
      case SailSVGAsset.scatterChart:
        return 'assets/svgs/scatter-chart.svg';
      case SailSVGAsset.lassoSelect:
        return 'assets/svgs/lasso-select.svg';
      case SailSVGAsset.arrowBigDown:
        return 'assets/svgs/arrow-big-down.svg';
      case SailSVGAsset.iterationCw:
        return 'assets/svgs/iteration-cw.svg';
      case SailSVGAsset.fullscreen:
        return 'assets/svgs/fullscreen.svg';
      case SailSVGAsset.messageCircleHeart:
        return 'assets/svgs/message-circle-heart.svg';
      case SailSVGAsset.sunDim:
        return 'assets/svgs/sun-dim.svg';
      case SailSVGAsset.iconOpenInNew:
        return 'assets/svgs/icon_open_in_new.svg';
      case SailSVGAsset.replaceAll:
        return 'assets/svgs/replace-all.svg';
      case SailSVGAsset.squareArrowOutDownLeft:
        return 'assets/svgs/square-arrow-out-down-left.svg';
      case SailSVGAsset.cannabis:
        return 'assets/svgs/cannabis.svg';
      case SailSVGAsset.iterationCcw:
        return 'assets/svgs/iteration-ccw.svg';
      case SailSVGAsset.messageCircleMore:
        return 'assets/svgs/message-circle-more.svg';
      case SailSVGAsset.fileMinus:
        return 'assets/svgs/file-minus.svg';
      case SailSVGAsset.squarePower:
        return 'assets/svgs/square-power.svg';
      case SailSVGAsset.squareChevronUp:
        return 'assets/svgs/square-chevron-up.svg';
      case SailSVGAsset.alignHorizontalJustifyStart:
        return 'assets/svgs/align-horizontal-justify-start.svg';
      case SailSVGAsset.copyPlus:
        return 'assets/svgs/copy-plus.svg';
      case SailSVGAsset.timerOff:
        return 'assets/svgs/timer-off.svg';
      case SailSVGAsset.folderCheck:
        return 'assets/svgs/folder-check.svg';
      case SailSVGAsset.badgeJapaneseYen:
        return 'assets/svgs/badge-japanese-yen.svg';
      case SailSVGAsset.arrowUpFromLine:
        return 'assets/svgs/arrow-up-from-line.svg';
      case SailSVGAsset.flipVertical2:
        return 'assets/svgs/flip-vertical-2.svg';
      case SailSVGAsset.annoyed:
        return 'assets/svgs/annoyed.svg';
      case SailSVGAsset.ligature:
        return 'assets/svgs/ligature.svg';
      case SailSVGAsset.messageSquareWarning:
        return 'assets/svgs/message-square-warning.svg';
      case SailSVGAsset.layoutGrid:
        return 'assets/svgs/layout-grid.svg';
      case SailSVGAsset.rockingChair:
        return 'assets/svgs/rocking-chair.svg';
      case SailSVGAsset.chevronsUpDown:
        return 'assets/svgs/chevrons-up-down.svg';
      case SailSVGAsset.badgeMinus:
        return 'assets/svgs/badge-minus.svg';
      case SailSVGAsset.calendarOff:
        return 'assets/svgs/calendar-off.svg';
      case SailSVGAsset.circle:
        return 'assets/svgs/circle.svg';
      case SailSVGAsset.airVent:
        return 'assets/svgs/air-vent.svg';
      case SailSVGAsset.phoneMissed:
        return 'assets/svgs/phone-missed.svg';
      case SailSVGAsset.scale3d:
        return 'assets/svgs/scale-3d.svg';
      case SailSVGAsset.cornerLeftUp:
        return 'assets/svgs/corner-left-up.svg';
      case SailSVGAsset.milk:
        return 'assets/svgs/milk.svg';
      case SailSVGAsset.clipboardPen:
        return 'assets/svgs/clipboard-pen.svg';
      case SailSVGAsset.home:
        return 'assets/svgs/home.svg';
      case SailSVGAsset.fileUp:
        return 'assets/svgs/file-up.svg';
      case SailSVGAsset.copyright:
        return 'assets/svgs/copyright.svg';
      case SailSVGAsset.pictureInPicture:
        return 'assets/svgs/picture-in-picture.svg';
      case SailSVGAsset.vault:
        return 'assets/svgs/vault.svg';
      case SailSVGAsset.circlePower:
        return 'assets/svgs/circle-power.svg';
      case SailSVGAsset.mailbox:
        return 'assets/svgs/mailbox.svg';
      case SailSVGAsset.gitlab:
        return 'assets/svgs/gitlab.svg';
      case SailSVGAsset.music:
        return 'assets/svgs/music.svg';
      case SailSVGAsset.fileBarChart2:
        return 'assets/svgs/file-bar-chart-2.svg';
      case SailSVGAsset.rectangleEllipsis:
        return 'assets/svgs/rectangle-ellipsis.svg';
      case SailSVGAsset.smartphone:
        return 'assets/svgs/smartphone.svg';
      case SailSVGAsset.fileSymlink:
        return 'assets/svgs/file-symlink.svg';
      case SailSVGAsset.alarmClockCheck:
        return 'assets/svgs/alarm-clock-check.svg';
      case SailSVGAsset.candyOff:
        return 'assets/svgs/candy-off.svg';
      case SailSVGAsset.circuitBoard:
        return 'assets/svgs/circuit-board.svg';
      case SailSVGAsset.folderTree:
        return 'assets/svgs/folder-tree.svg';
      case SailSVGAsset.equal:
        return 'assets/svgs/equal.svg';
      case SailSVGAsset.recycle:
        return 'assets/svgs/recycle.svg';
      case SailSVGAsset.arrowUpLeft:
        return 'assets/svgs/arrow-up-left.svg';
      case SailSVGAsset.clipboardType:
        return 'assets/svgs/clipboard-type.svg';
      case SailSVGAsset.library:
        return 'assets/svgs/library.svg';
      case SailSVGAsset.panelTopClose:
        return 'assets/svgs/panel-top-close.svg';
      case SailSVGAsset.filePieChart:
        return 'assets/svgs/file-pie-chart.svg';
      case SailSVGAsset.squareArrowDown:
        return 'assets/svgs/square-arrow-down.svg';
      case SailSVGAsset.listPlus:
        return 'assets/svgs/list-plus.svg';
      case SailSVGAsset.chevronDown:
        return 'assets/svgs/chevron-down.svg';
      case SailSVGAsset.backpack:
        return 'assets/svgs/backpack.svg';
      case SailSVGAsset.calendarCheck2:
        return 'assets/svgs/calendar-check-2.svg';
      case SailSVGAsset.heading:
        return 'assets/svgs/heading.svg';
      case SailSVGAsset.hexagon:
        return 'assets/svgs/hexagon.svg';
      case SailSVGAsset.strikethrough:
        return 'assets/svgs/strikethrough.svg';
      case SailSVGAsset.calendarFold:
        return 'assets/svgs/calendar-fold.svg';
      case SailSVGAsset.messageSquareHeart:
        return 'assets/svgs/message-square-heart.svg';
      case SailSVGAsset.bird:
        return 'assets/svgs/bird.svg';
      case SailSVGAsset.botMessageSquare:
        return 'assets/svgs/bot-message-square.svg';
      case SailSVGAsset.sunMedium:
        return 'assets/svgs/sun-medium.svg';
      case SailSVGAsset.badgeInfo:
        return 'assets/svgs/badge-info.svg';
      case SailSVGAsset.shieldPlus:
        return 'assets/svgs/shield-plus.svg';
      case SailSVGAsset.bookMarked:
        return 'assets/svgs/book-marked.svg';
      case SailSVGAsset.creativeCommons:
        return 'assets/svgs/creative-commons.svg';
      case SailSVGAsset.shirt:
        return 'assets/svgs/shirt.svg';
      case SailSVGAsset.dock:
        return 'assets/svgs/dock.svg';
      case SailSVGAsset.signpost:
        return 'assets/svgs/signpost.svg';
      case SailSVGAsset.doorClosed:
        return 'assets/svgs/door-closed.svg';
      case SailSVGAsset.github:
        return 'assets/svgs/github.svg';
      case SailSVGAsset.foldHorizontal:
        return 'assets/svgs/fold-horizontal.svg';
      case SailSVGAsset.nfc:
        return 'assets/svgs/nfc.svg';
      case SailSVGAsset.clipboardPaste:
        return 'assets/svgs/clipboard-paste.svg';
      case SailSVGAsset.cone:
        return 'assets/svgs/cone.svg';
      case SailSVGAsset.cookingPot:
        return 'assets/svgs/cooking-pot.svg';
      case SailSVGAsset.proportions:
        return 'assets/svgs/proportions.svg';
      case SailSVGAsset.bringToFront:
        return 'assets/svgs/bring-to-front.svg';
      case SailSVGAsset.usb:
        return 'assets/svgs/usb.svg';
      case SailSVGAsset.separatorVertical:
        return 'assets/svgs/separator-vertical.svg';
      case SailSVGAsset.boxSelect:
        return 'assets/svgs/box-select.svg';
      case SailSVGAsset.hardHat:
        return 'assets/svgs/hard-hat.svg';
      case SailSVGAsset.cakeSlice:
        return 'assets/svgs/cake-slice.svg';
      case SailSVGAsset.sunMoon:
        return 'assets/svgs/sun-moon.svg';
      case SailSVGAsset.ticket:
        return 'assets/svgs/ticket.svg';
      case SailSVGAsset.calendarPlus2:
        return 'assets/svgs/calendar-plus-2.svg';
      case SailSVGAsset.caseLower:
        return 'assets/svgs/case-lower.svg';
      case SailSVGAsset.layoutTemplate:
        return 'assets/svgs/layout-template.svg';
      case SailSVGAsset.panelRightOpen:
        return 'assets/svgs/panel-right-open.svg';
      case SailSVGAsset.brackets:
        return 'assets/svgs/brackets.svg';
      case SailSVGAsset.starOff:
        return 'assets/svgs/star-off.svg';
      case SailSVGAsset.shrink:
        return 'assets/svgs/shrink.svg';
      case SailSVGAsset.church:
        return 'assets/svgs/church.svg';
      case SailSVGAsset.circlePercent:
        return 'assets/svgs/circle-percent.svg';
      case SailSVGAsset.crop:
        return 'assets/svgs/crop.svg';
      case SailSVGAsset.flaskRound:
        return 'assets/svgs/flask-round.svg';
      case SailSVGAsset.cookie:
        return 'assets/svgs/cookie.svg';
      case SailSVGAsset.redo2:
        return 'assets/svgs/redo-2.svg';
      case SailSVGAsset.circleSlash2:
        return 'assets/svgs/circle-slash-2.svg';
      case SailSVGAsset.tag:
        return 'assets/svgs/tag.svg';
      case SailSVGAsset.bookCheck:
        return 'assets/svgs/book-check.svg';
      case SailSVGAsset.iconTabShieldDeshield:
        return 'assets/svgs/icon_tab_shield_deshield.svg';
      case SailSVGAsset.octagonPause:
        return 'assets/svgs/octagon-pause.svg';
      case SailSVGAsset.cupSoda:
        return 'assets/svgs/cup-soda.svg';
      case SailSVGAsset.option:
        return 'assets/svgs/option.svg';
      case SailSVGAsset.sparkle:
        return 'assets/svgs/sparkle.svg';
      case SailSVGAsset.briefcase:
        return 'assets/svgs/briefcase.svg';
      case SailSVGAsset.circleChevronDown:
        return 'assets/svgs/circle-chevron-down.svg';
      case SailSVGAsset.presentation:
        return 'assets/svgs/presentation.svg';
      case SailSVGAsset.squareSigma:
        return 'assets/svgs/square-sigma.svg';
      case SailSVGAsset.rotateCw:
        return 'assets/svgs/rotate-cw.svg';
      case SailSVGAsset.fileAudio:
        return 'assets/svgs/file-audio.svg';
      case SailSVGAsset.ellipsisVertical:
        return 'assets/svgs/ellipsis-vertical.svg';
      case SailSVGAsset.badgePlus:
        return 'assets/svgs/badge-plus.svg';
      case SailSVGAsset.screenShareOff:
        return 'assets/svgs/screen-share-off.svg';
      case SailSVGAsset.squarePlay:
        return 'assets/svgs/square-play.svg';
      case SailSVGAsset.alignHorizontalDistributeEnd:
        return 'assets/svgs/align-horizontal-distribute-end.svg';
      case SailSVGAsset.fileClock:
        return 'assets/svgs/file-clock.svg';
      case SailSVGAsset.calendarSearch:
        return 'assets/svgs/calendar-search.svg';
      case SailSVGAsset.imageDown:
        return 'assets/svgs/image-down.svg';
      case SailSVGAsset.swatchBook:
        return 'assets/svgs/swatch-book.svg';
      case SailSVGAsset.radius:
        return 'assets/svgs/radius.svg';
      case SailSVGAsset.folderSync:
        return 'assets/svgs/folder-sync.svg';
      case SailSVGAsset.panelsTopLeft:
        return 'assets/svgs/panels-top-left.svg';
      case SailSVGAsset.headset:
        return 'assets/svgs/headset.svg';
      case SailSVGAsset.circleEqual:
        return 'assets/svgs/circle-equal.svg';
      case SailSVGAsset.dessert:
        return 'assets/svgs/dessert.svg';
      case SailSVGAsset.carrot:
        return 'assets/svgs/carrot.svg';
      case SailSVGAsset.receiptEuro:
        return 'assets/svgs/receipt-euro.svg';
      case SailSVGAsset.map:
        return 'assets/svgs/map.svg';
      case SailSVGAsset.checkCheck:
        return 'assets/svgs/check-check.svg';
      case SailSVGAsset.inbox:
        return 'assets/svgs/inbox.svg';
      case SailSVGAsset.circleAlert:
        return 'assets/svgs/circle-alert.svg';
      case SailSVGAsset.tvMinimal:
        return 'assets/svgs/tv-minimal.svg';
      case SailSVGAsset.alignJustify:
        return 'assets/svgs/align-justify.svg';
      case SailSVGAsset.power:
        return 'assets/svgs/power.svg';
      case SailSVGAsset.aLargeSmall:
        return 'assets/svgs/a-large-small.svg';
      case SailSVGAsset.tentTree:
        return 'assets/svgs/tent-tree.svg';
      case SailSVGAsset.database:
        return 'assets/svgs/database.svg';
      case SailSVGAsset.captions:
        return 'assets/svgs/captions.svg';
      case SailSVGAsset.martini:
        return 'assets/svgs/martini.svg';
      case SailSVGAsset.arrowUpToLine:
        return 'assets/svgs/arrow-up-to-line.svg';
      case SailSVGAsset.monitorDown:
        return 'assets/svgs/monitor-down.svg';
      case SailSVGAsset.badgeIndianRupee:
        return 'assets/svgs/badge-indian-rupee.svg';
      case SailSVGAsset.cameraOff:
        return 'assets/svgs/camera-off.svg';
      case SailSVGAsset.fuel:
        return 'assets/svgs/fuel.svg';
      case SailSVGAsset.satelliteDish:
        return 'assets/svgs/satellite-dish.svg';
      case SailSVGAsset.bike:
        return 'assets/svgs/bike.svg';
      case SailSVGAsset.swords:
        return 'assets/svgs/swords.svg';
      case SailSVGAsset.messageSquareOff:
        return 'assets/svgs/message-square-off.svg';
      case SailSVGAsset.scanText:
        return 'assets/svgs/scan-text.svg';
      case SailSVGAsset.arrowDownZA:
        return 'assets/svgs/arrow-down-z-a.svg';
      case SailSVGAsset.rat:
        return 'assets/svgs/rat.svg';
      case SailSVGAsset.tornado:
        return 'assets/svgs/tornado.svg';
      case SailSVGAsset.toggleLeft:
        return 'assets/svgs/toggle-left.svg';
      case SailSVGAsset.file:
        return 'assets/svgs/file.svg';
      case SailSVGAsset.puzzle:
        return 'assets/svgs/puzzle.svg';
      case SailSVGAsset.alignVerticalDistributeCenter:
        return 'assets/svgs/align-vertical-distribute-center.svg';
      case SailSVGAsset.signal:
        return 'assets/svgs/signal.svg';
      case SailSVGAsset.eggOff:
        return 'assets/svgs/egg-off.svg';
      case SailSVGAsset.arrowUp10:
        return 'assets/svgs/arrow-up-1-0.svg';
      case SailSVGAsset.fileAudio2:
        return 'assets/svgs/file-audio-2.svg';
      case SailSVGAsset.baseline:
        return 'assets/svgs/baseline.svg';
      case SailSVGAsset.vibrateOff:
        return 'assets/svgs/vibrate-off.svg';
      case SailSVGAsset.glassWater:
        return 'assets/svgs/glass-water.svg';
      case SailSVGAsset.brain:
        return 'assets/svgs/brain.svg';
      case SailSVGAsset.files:
        return 'assets/svgs/files.svg';
      case SailSVGAsset.torus:
        return 'assets/svgs/torus.svg';
      case SailSVGAsset.scanSearch:
        return 'assets/svgs/scan-search.svg';
      case SailSVGAsset.squareDashedBottomCode:
        return 'assets/svgs/square-dashed-bottom-code.svg';
      case SailSVGAsset.messageCircle:
        return 'assets/svgs/message-circle.svg';
      case SailSVGAsset.messageSquareDot:
        return 'assets/svgs/message-square-dot.svg';
      case SailSVGAsset.receiptJapaneseYen:
        return 'assets/svgs/receipt-japanese-yen.svg';
      case SailSVGAsset.voicemail:
        return 'assets/svgs/voicemail.svg';
      case SailSVGAsset.messagesSquare:
        return 'assets/svgs/messages-square.svg';
      case SailSVGAsset.shipWheel:
        return 'assets/svgs/ship-wheel.svg';
      case SailSVGAsset.messageSquareQuote:
        return 'assets/svgs/message-square-quote.svg';
      case SailSVGAsset.contrast:
        return 'assets/svgs/contrast.svg';
      case SailSVGAsset.cuboid:
        return 'assets/svgs/cuboid.svg';
      case SailSVGAsset.alarmClockPlus:
        return 'assets/svgs/alarm-clock-plus.svg';
      case SailSVGAsset.monitorPause:
        return 'assets/svgs/monitor-pause.svg';
      case SailSVGAsset.fileVideo2:
        return 'assets/svgs/file-video-2.svg';
      case SailSVGAsset.archiveX:
        return 'assets/svgs/archive-x.svg';
      case SailSVGAsset.terminal:
        return 'assets/svgs/terminal.svg';
      case SailSVGAsset.moveDiagonal:
        return 'assets/svgs/move-diagonal.svg';
      case SailSVGAsset.fileScan:
        return 'assets/svgs/file-scan.svg';
      case SailSVGAsset.arrowUpWideNarrow:
        return 'assets/svgs/arrow-up-wide-narrow.svg';
      case SailSVGAsset.move:
        return 'assets/svgs/move.svg';
      case SailSVGAsset.maximize:
        return 'assets/svgs/maximize.svg';
      case SailSVGAsset.betweenVerticalStart:
        return 'assets/svgs/between-vertical-start.svg';
      case SailSVGAsset.laptopMinimal:
        return 'assets/svgs/laptop-minimal.svg';
      case SailSVGAsset.radar:
        return 'assets/svgs/radar.svg';
      case SailSVGAsset.sparkles:
        return 'assets/svgs/sparkles.svg';
      case SailSVGAsset.lockKeyhole:
        return 'assets/svgs/lock-keyhole.svg';
      case SailSVGAsset.octagonX:
        return 'assets/svgs/octagon-x.svg';
      case SailSVGAsset.folderRoot:
        return 'assets/svgs/folder-root.svg';
      case SailSVGAsset.chevronUp:
        return 'assets/svgs/chevron-up.svg';
      case SailSVGAsset.circleHelp:
        return 'assets/svgs/circle-help.svg';
      case SailSVGAsset.squarePercent:
        return 'assets/svgs/square-percent.svg';
      case SailSVGAsset.haze:
        return 'assets/svgs/haze.svg';
      case SailSVGAsset.folderOutput:
        return 'assets/svgs/folder-output.svg';
      case SailSVGAsset.folderSymlink:
        return 'assets/svgs/folder-symlink.svg';
      case SailSVGAsset.fileBadge2:
        return 'assets/svgs/file-badge-2.svg';
      case SailSVGAsset.vibrate:
        return 'assets/svgs/vibrate.svg';
      case SailSVGAsset.laugh:
        return 'assets/svgs/laugh.svg';
      case SailSVGAsset.scanEye:
        return 'assets/svgs/scan-eye.svg';
      case SailSVGAsset.spade:
        return 'assets/svgs/spade.svg';
      case SailSVGAsset.cloudRainWind:
        return 'assets/svgs/cloud-rain-wind.svg';
      case SailSVGAsset.slidersVertical:
        return 'assets/svgs/sliders-vertical.svg';
      case SailSVGAsset.undo2:
        return 'assets/svgs/undo-2.svg';
      case SailSVGAsset.fileVideo:
        return 'assets/svgs/file-video.svg';
      case SailSVGAsset.stepBack:
        return 'assets/svgs/step-back.svg';
      case SailSVGAsset.flaskConicalOff:
        return 'assets/svgs/flask-conical-off.svg';
      case SailSVGAsset.arrowDownLeft:
        return 'assets/svgs/arrow-down-left.svg';
      case SailSVGAsset.fileText:
        return 'assets/svgs/file-text.svg';
      case SailSVGAsset.fileStack:
        return 'assets/svgs/file-stack.svg';
      case SailSVGAsset.folderOpen:
        return 'assets/svgs/folder-open.svg';
      case SailSVGAsset.packageMinus:
        return 'assets/svgs/package-minus.svg';
      case SailSVGAsset.droplet:
        return 'assets/svgs/droplet.svg';
      case SailSVGAsset.wholeWord:
        return 'assets/svgs/whole-word.svg';
      case SailSVGAsset.paintRoller:
        return 'assets/svgs/paint-roller.svg';
      case SailSVGAsset.zapOff:
        return 'assets/svgs/zap-off.svg';
      case SailSVGAsset.squareKanban:
        return 'assets/svgs/square-kanban.svg';
      case SailSVGAsset.keyboard:
        return 'assets/svgs/keyboard.svg';
      case SailSVGAsset.x:
        return 'assets/svgs/x.svg';
      case SailSVGAsset.chevronsRightLeft:
        return 'assets/svgs/chevrons-right-left.svg';
      case SailSVGAsset.joystick:
        return 'assets/svgs/joystick.svg';
      case SailSVGAsset.cigarette:
        return 'assets/svgs/cigarette.svg';
      case SailSVGAsset.bath:
        return 'assets/svgs/bath.svg';
      case SailSVGAsset.barChart:
        return 'assets/svgs/bar-chart.svg';
      case SailSVGAsset.qrCode:
        return 'assets/svgs/qr-code.svg';
      case SailSVGAsset.dot:
        return 'assets/svgs/dot.svg';
      case SailSVGAsset.iceCreamCone:
        return 'assets/svgs/ice-cream-cone.svg';
      case SailSVGAsset.languages:
        return 'assets/svgs/languages.svg';
      case SailSVGAsset.ampersands:
        return 'assets/svgs/ampersands.svg';
      case SailSVGAsset.arrowLeftFromLine:
        return 'assets/svgs/arrow-left-from-line.svg';
      case SailSVGAsset.bellMinus:
        return 'assets/svgs/bell-minus.svg';
      case SailSVGAsset.fileCog:
        return 'assets/svgs/file-cog.svg';
      case SailSVGAsset.wheat:
        return 'assets/svgs/wheat.svg';
      case SailSVGAsset.cableCar:
        return 'assets/svgs/cable-car.svg';
      case SailSVGAsset.arrowUpNarrowWide:
        return 'assets/svgs/arrow-up-narrow-wide.svg';
      case SailSVGAsset.lock:
        return 'assets/svgs/lock.svg';
      case SailSVGAsset.dice2:
        return 'assets/svgs/dice-2.svg';
      case SailSVGAsset.logIn:
        return 'assets/svgs/log-in.svg';
      case SailSVGAsset.squircle:
        return 'assets/svgs/squircle.svg';
      case SailSVGAsset.cloudUpload:
        return 'assets/svgs/cloud-upload.svg';
      case SailSVGAsset.shieldEllipsis:
        return 'assets/svgs/shield-ellipsis.svg';
      case SailSVGAsset.ban:
        return 'assets/svgs/ban.svg';
      case SailSVGAsset.smartphoneNfc:
        return 'assets/svgs/smartphone-nfc.svg';
      case SailSVGAsset.listVideo:
        return 'assets/svgs/list-video.svg';
      case SailSVGAsset.textSelect:
        return 'assets/svgs/text-select.svg';
      case SailSVGAsset.shoppingBag:
        return 'assets/svgs/shopping-bag.svg';
      case SailSVGAsset.divide:
        return 'assets/svgs/divide.svg';
      case SailSVGAsset.piggyBank:
        return 'assets/svgs/piggy-bank.svg';
      case SailSVGAsset.batteryWarning:
        return 'assets/svgs/battery-warning.svg';
      case SailSVGAsset.walletMinimal:
        return 'assets/svgs/wallet-minimal.svg';
      case SailSVGAsset.circleDollarSign:
        return 'assets/svgs/circle-dollar-sign.svg';
      case SailSVGAsset.milkOff:
        return 'assets/svgs/milk-off.svg';
      case SailSVGAsset.squareParking:
        return 'assets/svgs/square-parking.svg';
      case SailSVGAsset.refreshCcwDot:
        return 'assets/svgs/refresh-ccw-dot.svg';
      case SailSVGAsset.tally2:
        return 'assets/svgs/tally-2.svg';
      case SailSVGAsset.shell:
        return 'assets/svgs/shell.svg';
      case SailSVGAsset.repeat2:
        return 'assets/svgs/repeat-2.svg';
      case SailSVGAsset.pilcrow:
        return 'assets/svgs/pilcrow.svg';
      case SailSVGAsset.circleDotDashed:
        return 'assets/svgs/circle-dot-dashed.svg';
      case SailSVGAsset.mailQuestion:
        return 'assets/svgs/mail-question.svg';
      case SailSVGAsset.cloudDrizzle:
        return 'assets/svgs/cloud-drizzle.svg';
      case SailSVGAsset.copyMinus:
        return 'assets/svgs/copy-minus.svg';
      case SailSVGAsset.spline:
        return 'assets/svgs/spline.svg';
      case SailSVGAsset.refreshCw:
        return 'assets/svgs/refresh-cw.svg';
      case SailSVGAsset.pen:
        return 'assets/svgs/pen.svg';
      case SailSVGAsset.plane:
        return 'assets/svgs/plane.svg';
      case SailSVGAsset.alignVerticalSpaceBetween:
        return 'assets/svgs/align-vertical-space-between.svg';
      case SailSVGAsset.chevronRight:
        return 'assets/svgs/chevron-right.svg';
      case SailSVGAsset.tally3:
        return 'assets/svgs/tally-3.svg';
      case SailSVGAsset.clipboard:
        return 'assets/svgs/clipboard.svg';
      case SailSVGAsset.equalNot:
        return 'assets/svgs/equal-not.svg';
      case SailSVGAsset.package:
        return 'assets/svgs/package.svg';
      case SailSVGAsset.instagram:
        return 'assets/svgs/instagram.svg';
      case SailSVGAsset.mailWarning:
        return 'assets/svgs/mail-warning.svg';
      case SailSVGAsset.euro:
        return 'assets/svgs/euro.svg';
      case SailSVGAsset.link:
        return 'assets/svgs/link.svg';
      case SailSVGAsset.squareChevronLeft:
        return 'assets/svgs/square-chevron-left.svg';
      case SailSVGAsset.globeLock:
        return 'assets/svgs/globe-lock.svg';
      case SailSVGAsset.dice3:
        return 'assets/svgs/dice-3.svg';
      case SailSVGAsset.handPlatter:
        return 'assets/svgs/hand-platter.svg';
      case SailSVGAsset.videoOff:
        return 'assets/svgs/video-off.svg';
      case SailSVGAsset.userRoundPlus:
        return 'assets/svgs/user-round-plus.svg';
      case SailSVGAsset.key:
        return 'assets/svgs/key.svg';
      case SailSVGAsset.squareActivity:
        return 'assets/svgs/square-activity.svg';
      case SailSVGAsset.shrub:
        return 'assets/svgs/shrub.svg';
      case SailSVGAsset.sailboat:
        return 'assets/svgs/sailboat.svg';
      case SailSVGAsset.fileX2:
        return 'assets/svgs/file-x-2.svg';
      case SailSVGAsset.squareSlash:
        return 'assets/svgs/square-slash.svg';
      case SailSVGAsset.brainCog:
        return 'assets/svgs/brain-cog.svg';
      case SailSVGAsset.meh:
        return 'assets/svgs/meh.svg';
      case SailSVGAsset.slidersHorizontal:
        return 'assets/svgs/sliders-horizontal.svg';
      case SailSVGAsset.doorOpen:
        return 'assets/svgs/door-open.svg';
      case SailSVGAsset.cornerDownRight:
        return 'assets/svgs/corner-down-right.svg';
      case SailSVGAsset.beaker:
        return 'assets/svgs/beaker.svg';
      case SailSVGAsset.listTodo:
        return 'assets/svgs/list-todo.svg';
      case SailSVGAsset.cloudSun:
        return 'assets/svgs/cloud-sun.svg';
      case SailSVGAsset.iconDownload:
        return 'assets/svgs/icon_download.svg';
      case SailSVGAsset.arrowRight:
        return 'assets/svgs/arrow-right.svg';
      case SailSVGAsset.store:
        return 'assets/svgs/store.svg';
      case SailSVGAsset.antenna:
        return 'assets/svgs/antenna.svg';
      case SailSVGAsset.chevronFirst:
        return 'assets/svgs/chevron-first.svg';
      case SailSVGAsset.wheatOff:
        return 'assets/svgs/wheat-off.svg';
      case SailSVGAsset.aperture:
        return 'assets/svgs/aperture.svg';
      case SailSVGAsset.calendarPlus:
        return 'assets/svgs/calendar-plus.svg';
      case SailSVGAsset.brush:
        return 'assets/svgs/brush.svg';
      case SailSVGAsset.thermometerSnowflake:
        return 'assets/svgs/thermometer-snowflake.svg';
      case SailSVGAsset.clover:
        return 'assets/svgs/clover.svg';
      case SailSVGAsset.conciergeBell:
        return 'assets/svgs/concierge-bell.svg';
      case SailSVGAsset.logOut:
        return 'assets/svgs/log-out.svg';
      case SailSVGAsset.unfoldHorizontal:
        return 'assets/svgs/unfold-horizontal.svg';
      case SailSVGAsset.fileSpreadsheet:
        return 'assets/svgs/file-spreadsheet.svg';
      case SailSVGAsset.squareRadical:
        return 'assets/svgs/square-radical.svg';
      case SailSVGAsset.circlePlay:
        return 'assets/svgs/circle-play.svg';
      case SailSVGAsset.squareArrowUp:
        return 'assets/svgs/square-arrow-up.svg';
      case SailSVGAsset.fileCode2:
        return 'assets/svgs/file-code-2.svg';
      case SailSVGAsset.telescope:
        return 'assets/svgs/telescope.svg';
      case SailSVGAsset.ship:
        return 'assets/svgs/ship.svg';
      case SailSVGAsset.earOff:
        return 'assets/svgs/ear-off.svg';
      case SailSVGAsset.worm:
        return 'assets/svgs/worm.svg';
      case SailSVGAsset.wallpaper:
        return 'assets/svgs/wallpaper.svg';
      case SailSVGAsset.ambulance:
        return 'assets/svgs/ambulance.svg';
      case SailSVGAsset.space:
        return 'assets/svgs/space.svg';
      case SailSVGAsset.fileInput:
        return 'assets/svgs/file-input.svg';
      case SailSVGAsset.barChart2:
        return 'assets/svgs/bar-chart-2.svg';
      case SailSVGAsset.bookDashed:
        return 'assets/svgs/book-dashed.svg';
      case SailSVGAsset.stretchVertical:
        return 'assets/svgs/stretch-vertical.svg';
      case SailSVGAsset.calendarCheck:
        return 'assets/svgs/calendar-check.svg';
      case SailSVGAsset.diff:
        return 'assets/svgs/diff.svg';
      case SailSVGAsset.showerHead:
        return 'assets/svgs/shower-head.svg';
      case SailSVGAsset.squarePen:
        return 'assets/svgs/square-pen.svg';
      case SailSVGAsset.arrowDownUp:
        return 'assets/svgs/arrow-down-up.svg';
      case SailSVGAsset.gitPullRequest:
        return 'assets/svgs/git-pull-request.svg';
      case SailSVGAsset.minimize:
        return 'assets/svgs/minimize.svg';
      case SailSVGAsset.group:
        return 'assets/svgs/group.svg';
      case SailSVGAsset.settings:
        return 'assets/svgs/settings.svg';
      case SailSVGAsset.cloudSnow:
        return 'assets/svgs/cloud-snow.svg';
      case SailSVGAsset.notepadTextDashed:
        return 'assets/svgs/notepad-text-dashed.svg';
      case SailSVGAsset.calendarX2:
        return 'assets/svgs/calendar-x-2.svg';
      case SailSVGAsset.cassetteTape:
        return 'assets/svgs/cassette-tape.svg';
      case SailSVGAsset.thumbsDown:
        return 'assets/svgs/thumbs-down.svg';
      case SailSVGAsset.dice1:
        return 'assets/svgs/dice-1.svg';
      case SailSVGAsset.moveDownLeft:
        return 'assets/svgs/move-down-left.svg';
      case SailSVGAsset.vote:
        return 'assets/svgs/vote.svg';
      case SailSVGAsset.botOff:
        return 'assets/svgs/bot-off.svg';
      case SailSVGAsset.type:
        return 'assets/svgs/type.svg';
      case SailSVGAsset.squareDashedMousePointer:
        return 'assets/svgs/square-dashed-mouse-pointer.svg';
      case SailSVGAsset.squareMenu:
        return 'assets/svgs/square-menu.svg';
      case SailSVGAsset.mousePointerClick:
        return 'assets/svgs/mouse-pointer-click.svg';
      case SailSVGAsset.regex:
        return 'assets/svgs/regex.svg';
      case SailSVGAsset.squareCheckBig:
        return 'assets/svgs/square-check-big.svg';
      case SailSVGAsset.loaderCircle:
        return 'assets/svgs/loader-circle.svg';
      case SailSVGAsset.popsicle:
        return 'assets/svgs/popsicle.svg';
      case SailSVGAsset.lampFloor:
        return 'assets/svgs/lamp-floor.svg';
      case SailSVGAsset.utensils:
        return 'assets/svgs/utensils.svg';
      case SailSVGAsset.archive:
        return 'assets/svgs/archive.svg';
      case SailSVGAsset.bean:
        return 'assets/svgs/bean.svg';
      case SailSVGAsset.panelsRightBottom:
        return 'assets/svgs/panels-right-bottom.svg';
      case SailSVGAsset.messageSquareText:
        return 'assets/svgs/message-square-text.svg';
      case SailSVGAsset.refreshCwOff:
        return 'assets/svgs/refresh-cw-off.svg';
      case SailSVGAsset.phoneOutgoing:
        return 'assets/svgs/phone-outgoing.svg';
      case SailSVGAsset.tally1:
        return 'assets/svgs/tally-1.svg';
      case SailSVGAsset.arrowUpFromDot:
        return 'assets/svgs/arrow-up-from-dot.svg';
      case SailSVGAsset.candy:
        return 'assets/svgs/candy.svg';
      case SailSVGAsset.pocket:
        return 'assets/svgs/pocket.svg';
      case SailSVGAsset.repeat1:
        return 'assets/svgs/repeat-1.svg';
      case SailSVGAsset.magnet:
        return 'assets/svgs/magnet.svg';
      case SailSVGAsset.circleParking:
        return 'assets/svgs/circle-parking.svg';
      case SailSVGAsset.mail:
        return 'assets/svgs/mail.svg';
      case SailSVGAsset.school:
        return 'assets/svgs/school.svg';
      case SailSVGAsset.arrowBigRight:
        return 'assets/svgs/arrow-big-right.svg';
      case SailSVGAsset.shield:
        return 'assets/svgs/shield.svg';
      case SailSVGAsset.download:
        return 'assets/svgs/download.svg';
      case SailSVGAsset.kanban:
        return 'assets/svgs/kanban.svg';
      case SailSVGAsset.fileVolume:
        return 'assets/svgs/file-volume.svg';
      case SailSVGAsset.expand:
        return 'assets/svgs/expand.svg';
      case SailSVGAsset.galleryVerticalEnd:
        return 'assets/svgs/gallery-vertical-end.svg';
      case SailSVGAsset.fileWarning:
        return 'assets/svgs/file-warning.svg';
      case SailSVGAsset.discAlbum:
        return 'assets/svgs/disc-album.svg';
      case SailSVGAsset.pin:
        return 'assets/svgs/pin.svg';
      case SailSVGAsset.arrowUpAZ:
        return 'assets/svgs/arrow-up-a-z.svg';
      case SailSVGAsset.squareCheck:
        return 'assets/svgs/square-check.svg';
      case SailSVGAsset.barChartHorizontalBig:
        return 'assets/svgs/bar-chart-horizontal-big.svg';
      case SailSVGAsset.import:
        return 'assets/svgs/import.svg';
      case SailSVGAsset.webcam:
        return 'assets/svgs/webcam.svg';
      case SailSVGAsset.phoneForwarded:
        return 'assets/svgs/phone-forwarded.svg';
      case SailSVGAsset.bellPlus:
        return 'assets/svgs/bell-plus.svg';
      case SailSVGAsset.squareDot:
        return 'assets/svgs/square-dot.svg';
      case SailSVGAsset.cornerRightDown:
        return 'assets/svgs/corner-right-down.svg';
      case SailSVGAsset.squareDivide:
        return 'assets/svgs/square-divide.svg';
      case SailSVGAsset.bookOpen:
        return 'assets/svgs/book-open.svg';
      case SailSVGAsset.forklift:
        return 'assets/svgs/forklift.svg';
      case SailSVGAsset.calendarCog:
        return 'assets/svgs/calendar-cog.svg';
      case SailSVGAsset.castle:
        return 'assets/svgs/castle.svg';
      case SailSVGAsset.areaChart:
        return 'assets/svgs/area-chart.svg';
      case SailSVGAsset.orbit:
        return 'assets/svgs/orbit.svg';
      case SailSVGAsset.parentheses:
        return 'assets/svgs/parentheses.svg';
      case SailSVGAsset.projector:
        return 'assets/svgs/projector.svg';
      case SailSVGAsset.pilcrowRight:
        return 'assets/svgs/pilcrow-right.svg';
      case SailSVGAsset.server:
        return 'assets/svgs/server.svg';
      case SailSVGAsset.userRoundCheck:
        return 'assets/svgs/user-round-check.svg';
      case SailSVGAsset.bolt:
        return 'assets/svgs/bolt.svg';
      case SailSVGAsset.tv:
        return 'assets/svgs/tv.svg';
      case SailSVGAsset.messageSquareDashed:
        return 'assets/svgs/message-square-dashed.svg';
      case SailSVGAsset.droplets:
        return 'assets/svgs/droplets.svg';
      case SailSVGAsset.skipForward:
        return 'assets/svgs/skip-forward.svg';
      case SailSVGAsset.archiveRestore:
        return 'assets/svgs/archive-restore.svg';
      case SailSVGAsset.volume:
        return 'assets/svgs/volume.svg';
      case SailSVGAsset.lampWallUp:
        return 'assets/svgs/lamp-wall-up.svg';
      case SailSVGAsset.barChart3:
        return 'assets/svgs/bar-chart-3.svg';
      case SailSVGAsset.drumstick:
        return 'assets/svgs/drumstick.svg';
      case SailSVGAsset.userPlus:
        return 'assets/svgs/user-plus.svg';
      case SailSVGAsset.batteryMedium:
        return 'assets/svgs/battery-medium.svg';
      case SailSVGAsset.bookA:
        return 'assets/svgs/book-a.svg';
      case SailSVGAsset.batteryCharging:
        return 'assets/svgs/battery-charging.svg';
      case SailSVGAsset.shapes:
        return 'assets/svgs/shapes.svg';
      case SailSVGAsset.folders:
        return 'assets/svgs/folders.svg';
      case SailSVGAsset.satellite:
        return 'assets/svgs/satellite.svg';
      case SailSVGAsset.listMinus:
        return 'assets/svgs/list-minus.svg';
      case SailSVGAsset.circleArrowLeft:
        return 'assets/svgs/circle-arrow-left.svg';
      case SailSVGAsset.bookmarkMinus:
        return 'assets/svgs/bookmark-minus.svg';
      case SailSVGAsset.heater:
        return 'assets/svgs/heater.svg';
      case SailSVGAsset.layers:
        return 'assets/svgs/layers.svg';
      case SailSVGAsset.earthLock:
        return 'assets/svgs/earth-lock.svg';
      case SailSVGAsset.squareParkingOff:
        return 'assets/svgs/square-parking-off.svg';
      case SailSVGAsset.dna:
        return 'assets/svgs/dna.svg';
      case SailSVGAsset.mouseOff:
        return 'assets/svgs/mouse-off.svg';
      case SailSVGAsset.fileCheck2:
        return 'assets/svgs/file-check-2.svg';
      case SailSVGAsset.slash:
        return 'assets/svgs/slash.svg';
      case SailSVGAsset.radio:
        return 'assets/svgs/radio.svg';
      case SailSVGAsset.alignCenterVertical:
        return 'assets/svgs/align-center-vertical.svg';
      case SailSVGAsset.alarmClock:
        return 'assets/svgs/alarm-clock.svg';
      case SailSVGAsset.alarmClockOff:
        return 'assets/svgs/alarm-clock-off.svg';
      case SailSVGAsset.book:
        return 'assets/svgs/book.svg';
      case SailSVGAsset.keyboardMusic:
        return 'assets/svgs/keyboard-music.svg';
      case SailSVGAsset.hotel:
        return 'assets/svgs/hotel.svg';
      case SailSVGAsset.bookText:
        return 'assets/svgs/book-text.svg';
      case SailSVGAsset.variable:
        return 'assets/svgs/variable.svg';
      case SailSVGAsset.touchpadOff:
        return 'assets/svgs/touchpad-off.svg';
      case SailSVGAsset.bitcoin:
        return 'assets/svgs/bitcoin.svg';
      case SailSVGAsset.messageSquareX:
        return 'assets/svgs/message-square-x.svg';
      case SailSVGAsset.carFront:
        return 'assets/svgs/car-front.svg';
      case SailSVGAsset.alarmSmoke:
        return 'assets/svgs/alarm-smoke.svg';
      case SailSVGAsset.dice4:
        return 'assets/svgs/dice-4.svg';
      case SailSVGAsset.skull:
        return 'assets/svgs/skull.svg';
      case SailSVGAsset.mailMinus:
        return 'assets/svgs/mail-minus.svg';
      case SailSVGAsset.bot:
        return 'assets/svgs/bot.svg';
      case SailSVGAsset.plug:
        return 'assets/svgs/plug.svg';
      case SailSVGAsset.shieldX:
        return 'assets/svgs/shield-x.svg';
      case SailSVGAsset.trainTrack:
        return 'assets/svgs/train-track.svg';
      case SailSVGAsset.goal:
        return 'assets/svgs/goal.svg';
      case SailSVGAsset.folderArchive:
        return 'assets/svgs/folder-archive.svg';
      case SailSVGAsset.signalHigh:
        return 'assets/svgs/signal-high.svg';
      case SailSVGAsset.userMinus:
        return 'assets/svgs/user-minus.svg';
      case SailSVGAsset.planeLanding:
        return 'assets/svgs/plane-landing.svg';
      case SailSVGAsset.wallet:
        return 'assets/svgs/wallet.svg';
      case SailSVGAsset.circleCheck:
        return 'assets/svgs/circle-check.svg';
      case SailSVGAsset.tally4:
        return 'assets/svgs/tally-4.svg';
      case SailSVGAsset.fileImage:
        return 'assets/svgs/file-image.svg';
      case SailSVGAsset.squareDashedBottom:
        return 'assets/svgs/square-dashed-bottom.svg';
      case SailSVGAsset.panelTopOpen:
        return 'assets/svgs/panel-top-open.svg';
      case SailSVGAsset.bell:
        return 'assets/svgs/bell.svg';
      case SailSVGAsset.gitBranch:
        return 'assets/svgs/git-branch.svg';
      case SailSVGAsset.squareM:
        return 'assets/svgs/square-m.svg';
      case SailSVGAsset.coffee:
        return 'assets/svgs/coffee.svg';
      case SailSVGAsset.panelLeftDashed:
        return 'assets/svgs/panel-left-dashed.svg';
      case SailSVGAsset.code:
        return 'assets/svgs/code.svg';
      case SailSVGAsset.railSymbol:
        return 'assets/svgs/rail-symbol.svg';
      case SailSVGAsset.circleDivide:
        return 'assets/svgs/circle-divide.svg';
      case SailSVGAsset.cake:
        return 'assets/svgs/cake.svg';
      case SailSVGAsset.spellCheck2:
        return 'assets/svgs/spell-check-2.svg';
      case SailSVGAsset.settings2:
        return 'assets/svgs/settings-2.svg';
      case SailSVGAsset.tally5:
        return 'assets/svgs/tally-5.svg';
      case SailSVGAsset.messageCircleDashed:
        return 'assets/svgs/message-circle-dashed.svg';
      case SailSVGAsset.cloudMoonRain:
        return 'assets/svgs/cloud-moon-rain.svg';
      case SailSVGAsset.radioTower:
        return 'assets/svgs/radio-tower.svg';
      case SailSVGAsset.thermometer:
        return 'assets/svgs/thermometer.svg';
      case SailSVGAsset.cast:
        return 'assets/svgs/cast.svg';
      case SailSVGAsset.milestone:
        return 'assets/svgs/milestone.svg';
      case SailSVGAsset.move3d:
        return 'assets/svgs/move-3d.svg';
      case SailSVGAsset.flag:
        return 'assets/svgs/flag.svg';
      case SailSVGAsset.podcast:
        return 'assets/svgs/podcast.svg';
      case SailSVGAsset.tvMinimalPlay:
        return 'assets/svgs/tv-minimal-play.svg';
      case SailSVGAsset.gitFork:
        return 'assets/svgs/git-fork.svg';
      case SailSVGAsset.eyeOff:
        return 'assets/svgs/eye-off.svg';
      case SailSVGAsset.dice5:
        return 'assets/svgs/dice-5.svg';
      case SailSVGAsset.tramFront:
        return 'assets/svgs/tram-front.svg';
      case SailSVGAsset.battery:
        return 'assets/svgs/battery.svg';
      case SailSVGAsset.blinds:
        return 'assets/svgs/blinds.svg';
      case SailSVGAsset.arrowLeftToLine:
        return 'assets/svgs/arrow-left-to-line.svg';
      case SailSVGAsset.newspaper:
        return 'assets/svgs/newspaper.svg';
      case SailSVGAsset.clipboardPenLine:
        return 'assets/svgs/clipboard-pen-line.svg';
      case SailSVGAsset.snowflake:
        return 'assets/svgs/snowflake.svg';
      case SailSVGAsset.disc:
        return 'assets/svgs/disc.svg';
      case SailSVGAsset.stepForward:
        return 'assets/svgs/step-forward.svg';
      case SailSVGAsset.bomb:
        return 'assets/svgs/bomb.svg';
      case SailSVGAsset.piano:
        return 'assets/svgs/piano.svg';
      case SailSVGAsset.bookCopy:
        return 'assets/svgs/book-copy.svg';
      case SailSVGAsset.arrowUp01:
        return 'assets/svgs/arrow-up-0-1.svg';
      case SailSVGAsset.databaseZap:
        return 'assets/svgs/database-zap.svg';
      case SailSVGAsset.rotate3d:
        return 'assets/svgs/rotate-3d.svg';
      case SailSVGAsset.starHalf:
        return 'assets/svgs/star-half.svg';
      case SailSVGAsset.switchCamera:
        return 'assets/svgs/switch-camera.svg';
      case SailSVGAsset.imagePlus:
        return 'assets/svgs/image-plus.svg';
      case SailSVGAsset.pencilRuler:
        return 'assets/svgs/pencil-ruler.svg';
      case SailSVGAsset.container:
        return 'assets/svgs/container.svg';
      case SailSVGAsset.ruler:
        return 'assets/svgs/ruler.svg';
      case SailSVGAsset.turtle:
        return 'assets/svgs/turtle.svg';
      case SailSVGAsset.frown:
        return 'assets/svgs/frown.svg';
      case SailSVGAsset.treePine:
        return 'assets/svgs/tree-pine.svg';
      case SailSVGAsset.audioLines:
        return 'assets/svgs/audio-lines.svg';
      case SailSVGAsset.circleSlash:
        return 'assets/svgs/circle-slash.svg';
      case SailSVGAsset.notebookText:
        return 'assets/svgs/notebook-text.svg';
      case SailSVGAsset.layoutDashboard:
        return 'assets/svgs/layout-dashboard.svg';
      case SailSVGAsset.fileLineChart:
        return 'assets/svgs/file-line-chart.svg';
      case SailSVGAsset.cpu:
        return 'assets/svgs/cpu.svg';
      case SailSVGAsset.alignEndHorizontal:
        return 'assets/svgs/align-end-horizontal.svg';
      case SailSVGAsset.flameKindling:
        return 'assets/svgs/flame-kindling.svg';
      case SailSVGAsset.clipboardList:
        return 'assets/svgs/clipboard-list.svg';
      case SailSVGAsset.biohazard:
        return 'assets/svgs/biohazard.svg';
      case SailSVGAsset.barChart4:
        return 'assets/svgs/bar-chart-4.svg';
      case SailSVGAsset.folderX:
        return 'assets/svgs/folder-x.svg';
      case SailSVGAsset.bookOpenCheck:
        return 'assets/svgs/book-open-check.svg';
      case SailSVGAsset.listOrdered:
        return 'assets/svgs/list-ordered.svg';
      case SailSVGAsset.factory:
        return 'assets/svgs/factory.svg';
      case SailSVGAsset.bold:
        return 'assets/svgs/bold.svg';
      case SailSVGAsset.tablets:
        return 'assets/svgs/tablets.svg';
      case SailSVGAsset.fence:
        return 'assets/svgs/fence.svg';
      case SailSVGAsset.trophy:
        return 'assets/svgs/trophy.svg';
      case SailSVGAsset.hash:
        return 'assets/svgs/hash.svg';
      case SailSVGAsset.shieldMinus:
        return 'assets/svgs/shield-minus.svg';
      case SailSVGAsset.link2Off:
        return 'assets/svgs/link-2-off.svg';
      case SailSVGAsset.share2:
        return 'assets/svgs/share-2.svg';
      case SailSVGAsset.batteryFull:
        return 'assets/svgs/battery-full.svg';
      case SailSVGAsset.plus:
        return 'assets/svgs/plus.svg';
      case SailSVGAsset.monitorStop:
        return 'assets/svgs/monitor-stop.svg';
      case SailSVGAsset.panelBottom:
        return 'assets/svgs/panel-bottom.svg';
      case SailSVGAsset.clipboardMinus:
        return 'assets/svgs/clipboard-minus.svg';
      case SailSVGAsset.check:
        return 'assets/svgs/check.svg';
      case SailSVGAsset.alignVerticalJustifyEnd:
        return 'assets/svgs/align-vertical-justify-end.svg';
      case SailSVGAsset.rabbit:
        return 'assets/svgs/rabbit.svg';
      case SailSVGAsset.plugZap:
        return 'assets/svgs/plug-zap.svg';
      case SailSVGAsset.nut:
        return 'assets/svgs/nut.svg';
      case SailSVGAsset.mailPlus:
        return 'assets/svgs/mail-plus.svg';
      case SailSVGAsset.moveDownRight:
        return 'assets/svgs/move-down-right.svg';
      case SailSVGAsset.rotateCcw:
        return 'assets/svgs/rotate-ccw.svg';
      case SailSVGAsset.heartCrack:
        return 'assets/svgs/heart-crack.svg';
      case SailSVGAsset.flipHorizontal2:
        return 'assets/svgs/flip-horizontal-2.svg';
      case SailSVGAsset.hardDrive:
        return 'assets/svgs/hard-drive.svg';
      case SailSVGAsset.betweenHorizontalEnd:
        return 'assets/svgs/between-horizontal-end.svg';
      case SailSVGAsset.tent:
        return 'assets/svgs/tent.svg';
      case SailSVGAsset.hardDriveDownload:
        return 'assets/svgs/hard-drive-download.svg';
      case SailSVGAsset.circleFadingPlus:
        return 'assets/svgs/circle-fading-plus.svg';
      case SailSVGAsset.penLine:
        return 'assets/svgs/pen-line.svg';
      case SailSVGAsset.alignVerticalSpaceAround:
        return 'assets/svgs/align-vertical-space-around.svg';
      case SailSVGAsset.hospital:
        return 'assets/svgs/hospital.svg';
      case SailSVGAsset.caseSensitive:
        return 'assets/svgs/case-sensitive.svg';
      case SailSVGAsset.focus:
        return 'assets/svgs/focus.svg';
      case SailSVGAsset.bluetooth:
        return 'assets/svgs/bluetooth.svg';
      case SailSVGAsset.alignEndVertical:
        return 'assets/svgs/align-end-vertical.svg';
      case SailSVGAsset.pieChart:
        return 'assets/svgs/pie-chart.svg';
      case SailSVGAsset.squareSplitVertical:
        return 'assets/svgs/square-split-vertical.svg';
      case SailSVGAsset.headphones:
        return 'assets/svgs/headphones.svg';
      case SailSVGAsset.tableProperties:
        return 'assets/svgs/table-properties.svg';
      case SailSVGAsset.gitPullRequestCreateArrow:
        return 'assets/svgs/git-pull-request-create-arrow.svg';
      case SailSVGAsset.folderGit2:
        return 'assets/svgs/folder-git-2.svg';
      case SailSVGAsset.squareX:
        return 'assets/svgs/square-x.svg';
      case SailSVGAsset.squareAsterisk:
        return 'assets/svgs/square-asterisk.svg';
      case SailSVGAsset.rss:
        return 'assets/svgs/rss.svg';
      case SailSVGAsset.tableCellsSplit:
        return 'assets/svgs/table-cells-split.svg';
      case SailSVGAsset.flower2:
        return 'assets/svgs/flower-2.svg';
      case SailSVGAsset.landmark:
        return 'assets/svgs/landmark.svg';
      case SailSVGAsset.wifi:
        return 'assets/svgs/wifi.svg';
      case SailSVGAsset.cornerUpLeft:
        return 'assets/svgs/corner-up-left.svg';
      case SailSVGAsset.fileArchive:
        return 'assets/svgs/file-archive.svg';
      case SailSVGAsset.squareArrowUpLeft:
        return 'assets/svgs/square-arrow-up-left.svg';
      case SailSVGAsset.arrowDownFromLine:
        return 'assets/svgs/arrow-down-from-line.svg';
      case SailSVGAsset.watch:
        return 'assets/svgs/watch.svg';
      case SailSVGAsset.squareArrowDownRight:
        return 'assets/svgs/square-arrow-down-right.svg';
      case SailSVGAsset.scale:
        return 'assets/svgs/scale.svg';
      case SailSVGAsset.dice6:
        return 'assets/svgs/dice-6.svg';
      case SailSVGAsset.messageSquareMore:
        return 'assets/svgs/message-square-more.svg';
      case SailSVGAsset.ampersand:
        return 'assets/svgs/ampersand.svg';
      case SailSVGAsset.dnaOff:
        return 'assets/svgs/dna-off.svg';
      case SailSVGAsset.squareArrowOutUpRight:
        return 'assets/svgs/square-arrow-out-up-right.svg';
      case SailSVGAsset.handCoins:
        return 'assets/svgs/hand-coins.svg';
      case SailSVGAsset.rollerCoaster:
        return 'assets/svgs/roller-coaster.svg';
      case SailSVGAsset.monitorSmartphone:
        return 'assets/svgs/monitor-smartphone.svg';
      case SailSVGAsset.gitCommitVertical:
        return 'assets/svgs/git-commit-vertical.svg';
      case SailSVGAsset.info:
        return 'assets/svgs/info.svg';
      case SailSVGAsset.blocks:
        return 'assets/svgs/blocks.svg';
      case SailSVGAsset.popcorn:
        return 'assets/svgs/popcorn.svg';
      case SailSVGAsset.fileBadge:
        return 'assets/svgs/file-badge.svg';
      case SailSVGAsset.badgeDollarSign:
        return 'assets/svgs/badge-dollar-sign.svg';
      case SailSVGAsset.userX:
        return 'assets/svgs/user-x.svg';
      case SailSVGAsset.navigationOff:
        return 'assets/svgs/navigation-off.svg';
      case SailSVGAsset.keySquare:
        return 'assets/svgs/key-square.svg';
      case SailSVGAsset.ticketMinus:
        return 'assets/svgs/ticket-minus.svg';
      case SailSVGAsset.dog:
        return 'assets/svgs/dog.svg';
      case SailSVGAsset.layoutPanelLeft:
        return 'assets/svgs/layout-panel-left.svg';
      case SailSVGAsset.fan:
        return 'assets/svgs/fan.svg';
      case SailSVGAsset.radioReceiver:
        return 'assets/svgs/radio-receiver.svg';
      case SailSVGAsset.loader:
        return 'assets/svgs/loader.svg';
      case SailSVGAsset.palette:
        return 'assets/svgs/palette.svg';
      case SailSVGAsset.pilcrowLeft:
        return 'assets/svgs/pilcrow-left.svg';
      case SailSVGAsset.diamondPlus:
        return 'assets/svgs/diamond-plus.svg';
      case SailSVGAsset.circleArrowOutDownLeft:
        return 'assets/svgs/circle-arrow-out-down-left.svg';
      case SailSVGAsset.receiptSwissFranc:
        return 'assets/svgs/receipt-swiss-franc.svg';
      case SailSVGAsset.package2:
        return 'assets/svgs/package-2.svg';
      case SailSVGAsset.caseUpper:
        return 'assets/svgs/case-upper.svg';
      case SailSVGAsset.refreshCcw:
        return 'assets/svgs/refresh-ccw.svg';
      case SailSVGAsset.cloudFog:
        return 'assets/svgs/cloud-fog.svg';
      case SailSVGAsset.iconArrowDown:
        return 'assets/svgs/icon_arrow_down.svg';
      case SailSVGAsset.gitBranchPlus:
        return 'assets/svgs/git-branch-plus.svg';
      case SailSVGAsset.fileX:
        return 'assets/svgs/file-x.svg';
      case SailSVGAsset.heading1:
        return 'assets/svgs/heading-1.svg';
      case SailSVGAsset.hop:
        return 'assets/svgs/hop.svg';
      case SailSVGAsset.folderUp:
        return 'assets/svgs/folder-up.svg';
      case SailSVGAsset.soup:
        return 'assets/svgs/soup.svg';
      case SailSVGAsset.folderPlus:
        return 'assets/svgs/folder-plus.svg';
      case SailSVGAsset.badgeRussianRuble:
        return 'assets/svgs/badge-russian-ruble.svg';
      case SailSVGAsset.gitMerge:
        return 'assets/svgs/git-merge.svg';
      case SailSVGAsset.japaneseYen:
        return 'assets/svgs/japanese-yen.svg';
      case SailSVGAsset.gripHorizontal:
        return 'assets/svgs/grip-horizontal.svg';
      case SailSVGAsset.listX:
        return 'assets/svgs/list-x.svg';
      case SailSVGAsset.shieldHalf:
        return 'assets/svgs/shield-half.svg';
      case SailSVGAsset.mic:
        return 'assets/svgs/mic.svg';
      case SailSVGAsset.venetianMask:
        return 'assets/svgs/venetian-mask.svg';
      case SailSVGAsset.rainbow:
        return 'assets/svgs/rainbow.svg';
      case SailSVGAsset.gitPullRequestArrow:
        return 'assets/svgs/git-pull-request-arrow.svg';
      case SailSVGAsset.copy:
        return 'assets/svgs/copy.svg';
      case SailSVGAsset.smilePlus:
        return 'assets/svgs/smile-plus.svg';
      case SailSVGAsset.fish:
        return 'assets/svgs/fish.svg';
      case SailSVGAsset.moveUpLeft:
        return 'assets/svgs/move-up-left.svg';
      case SailSVGAsset.listTree:
        return 'assets/svgs/list-tree.svg';
      case SailSVGAsset.zoomIn:
        return 'assets/svgs/zoom-in.svg';
      case SailSVGAsset.circleChevronUp:
        return 'assets/svgs/circle-chevron-up.svg';
      case SailSVGAsset.circleArrowOutDownRight:
        return 'assets/svgs/circle-arrow-out-down-right.svg';
      case SailSVGAsset.squareGanttChart:
        return 'assets/svgs/square-gantt-chart.svg';
      case SailSVGAsset.searchCheck:
        return 'assets/svgs/search-check.svg';
      case SailSVGAsset.arrowDownToLine:
        return 'assets/svgs/arrow-down-to-line.svg';
      case SailSVGAsset.glasses:
        return 'assets/svgs/glasses.svg';
      case SailSVGAsset.coins:
        return 'assets/svgs/coins.svg';
      case SailSVGAsset.alignStartVertical:
        return 'assets/svgs/align-start-vertical.svg';
      case SailSVGAsset.arrowsUpFromLine:
        return 'assets/svgs/arrows-up-from-line.svg';
      case SailSVGAsset.iconHdwallet:
        return 'assets/svgs/icon_hdwallet.svg';
      case SailSVGAsset.snail:
        return 'assets/svgs/snail.svg';
      case SailSVGAsset.libraryBig:
        return 'assets/svgs/library-big.svg';
      case SailSVGAsset.bookmarkX:
        return 'assets/svgs/bookmark-x.svg';
      case SailSVGAsset.bookKey:
        return 'assets/svgs/book-key.svg';
      case SailSVGAsset.panelLeft:
        return 'assets/svgs/panel-left.svg';
      case SailSVGAsset.testTubeDiagonal:
        return 'assets/svgs/test-tube-diagonal.svg';
      case SailSVGAsset.origami:
        return 'assets/svgs/origami.svg';
      case SailSVGAsset.squareLibrary:
        return 'assets/svgs/square-library.svg';
      case SailSVGAsset.messageCircleOff:
        return 'assets/svgs/message-circle-off.svg';
      case SailSVGAsset.squareUserRound:
        return 'assets/svgs/square-user-round.svg';
      case SailSVGAsset.wandSparkles:
        return 'assets/svgs/wand-sparkles.svg';
      case SailSVGAsset.fileType2:
        return 'assets/svgs/file-type-2.svg';
      case SailSVGAsset.textQuote:
        return 'assets/svgs/text-quote.svg';
      case SailSVGAsset.caravan:
        return 'assets/svgs/caravan.svg';
      case SailSVGAsset.badgeCent:
        return 'assets/svgs/badge-cent.svg';
      case SailSVGAsset.panelTopDashed:
        return 'assets/svgs/panel-top-dashed.svg';
      case SailSVGAsset.notebookTabs:
        return 'assets/svgs/notebook-tabs.svg';
      case SailSVGAsset.text:
        return 'assets/svgs/text.svg';
      case SailSVGAsset.testTubes:
        return 'assets/svgs/test-tubes.svg';
      case SailSVGAsset.fireExtinguisher:
        return 'assets/svgs/fire-extinguisher.svg';
      case SailSVGAsset.eggFried:
        return 'assets/svgs/egg-fried.svg';
      case SailSVGAsset.flagTriangleLeft:
        return 'assets/svgs/flag-triangle-left.svg';
      case SailSVGAsset.alignRight:
        return 'assets/svgs/align-right.svg';
      case SailSVGAsset.textCursor:
        return 'assets/svgs/text-cursor.svg';
      case SailSVGAsset.image:
        return 'assets/svgs/image.svg';
      case SailSVGAsset.panelBottomOpen:
        return 'assets/svgs/panel-bottom-open.svg';
      case SailSVGAsset.maximize2:
        return 'assets/svgs/maximize-2.svg';
      case SailSVGAsset.iconTabSend:
        return 'assets/svgs/icon_tab_send.svg';
      case SailSVGAsset.lightbulb:
        return 'assets/svgs/lightbulb.svg';
      case SailSVGAsset.serverOff:
        return 'assets/svgs/server-off.svg';
      case SailSVGAsset.arrowBigLeftDash:
        return 'assets/svgs/arrow-big-left-dash.svg';
      case SailSVGAsset.imagePlay:
        return 'assets/svgs/image-play.svg';
      case SailSVGAsset.sunset:
        return 'assets/svgs/sunset.svg';
      case SailSVGAsset.save:
        return 'assets/svgs/save.svg';
      case SailSVGAsset.smile:
        return 'assets/svgs/smile.svg';
      case SailSVGAsset.searchCode:
        return 'assets/svgs/search-code.svg';
      case SailSVGAsset.lamp:
        return 'assets/svgs/lamp.svg';
      case SailSVGAsset.siren:
        return 'assets/svgs/siren.svg';
      case SailSVGAsset.images:
        return 'assets/svgs/images.svg';
      case SailSVGAsset.scan:
        return 'assets/svgs/scan.svg';
      case SailSVGAsset.navigation:
        return 'assets/svgs/navigation.svg';
      case SailSVGAsset.cloudLightning:
        return 'assets/svgs/cloud-lightning.svg';
      case SailSVGAsset.iconDashboardTab:
        return 'assets/svgs/icon_dashboard_tab.svg';
      case SailSVGAsset.citrus:
        return 'assets/svgs/citrus.svg';
      case SailSVGAsset.messageSquareDiff:
        return 'assets/svgs/message-square-diff.svg';
      case SailSVGAsset.bellElectric:
        return 'assets/svgs/bell-electric.svg';
      case SailSVGAsset.ham:
        return 'assets/svgs/ham.svg';
      case SailSVGAsset.candlestickChart:
        return 'assets/svgs/candlestick-chart.svg';
      case SailSVGAsset.monitorPlay:
        return 'assets/svgs/monitor-play.svg';
      case SailSVGAsset.badgePoundSterling:
        return 'assets/svgs/badge-pound-sterling.svg';
      case SailSVGAsset.hardDriveUpload:
        return 'assets/svgs/hard-drive-upload.svg';
      case SailSVGAsset.appWindow:
        return 'assets/svgs/app-window.svg';
      case SailSVGAsset.badge:
        return 'assets/svgs/badge.svg';
      case SailSVGAsset.iconTabDepositWithdraw:
        return 'assets/svgs/icon_tab_deposit_withdraw.svg';
      case SailSVGAsset.theater:
        return 'assets/svgs/theater.svg';
      case SailSVGAsset.paperclip:
        return 'assets/svgs/paperclip.svg';
      case SailSVGAsset.heading2:
        return 'assets/svgs/heading-2.svg';
      case SailSVGAsset.squareScissors:
        return 'assets/svgs/square-scissors.svg';
      case SailSVGAsset.fastForward:
        return 'assets/svgs/fast-forward.svg';
      case SailSVGAsset.flagTriangleRight:
        return 'assets/svgs/flag-triangle-right.svg';
      case SailSVGAsset.calendarRange:
        return 'assets/svgs/calendar-range.svg';
      case SailSVGAsset.contactRound:
        return 'assets/svgs/contact-round.svg';
      case SailSVGAsset.syringe:
        return 'assets/svgs/syringe.svg';
      case SailSVGAsset.searchSlash:
        return 'assets/svgs/search-slash.svg';
      case SailSVGAsset.fileQuestion:
        return 'assets/svgs/file-question.svg';
      case SailSVGAsset.barChartHorizontal:
        return 'assets/svgs/bar-chart-horizontal.svg';
      case SailSVGAsset.sticker:
        return 'assets/svgs/sticker.svg';
      case SailSVGAsset.award:
        return 'assets/svgs/award.svg';
      case SailSVGAsset.panelRightDashed:
        return 'assets/svgs/panel-right-dashed.svg';
      case SailSVGAsset.zoomOut:
        return 'assets/svgs/zoom-out.svg';
      case SailSVGAsset.squareArrowOutUpLeft:
        return 'assets/svgs/square-arrow-out-up-left.svg';
      case SailSVGAsset.box:
        return 'assets/svgs/box.svg';
      case SailSVGAsset.thumbsUp:
        return 'assets/svgs/thumbs-up.svg';
      case SailSVGAsset.superscript:
        return 'assets/svgs/superscript.svg';
      case SailSVGAsset.ticketPercent:
        return 'assets/svgs/ticket-percent.svg';
      case SailSVGAsset.batteryLow:
        return 'assets/svgs/battery-low.svg';
      case SailSVGAsset.touchpad:
        return 'assets/svgs/touchpad.svg';
      case SailSVGAsset.speech:
        return 'assets/svgs/speech.svg';
      case SailSVGAsset.percent:
        return 'assets/svgs/percent.svg';
      case SailSVGAsset.squareChevronDown:
        return 'assets/svgs/square-chevron-down.svg';
      case SailSVGAsset.square:
        return 'assets/svgs/square.svg';
      case SailSVGAsset.crown:
        return 'assets/svgs/crown.svg';
      case SailSVGAsset.bluetoothSearching:
        return 'assets/svgs/bluetooth-searching.svg';
      case SailSVGAsset.timerReset:
        return 'assets/svgs/timer-reset.svg';
      case SailSVGAsset.stethoscope:
        return 'assets/svgs/stethoscope.svg';
      case SailSVGAsset.iconSidechain:
        return 'assets/svgs/icon_sidechain.svg';
      case SailSVGAsset.eclipse:
        return 'assets/svgs/eclipse.svg';
      case SailSVGAsset.donut:
        return 'assets/svgs/donut.svg';
      case SailSVGAsset.candyCane:
        return 'assets/svgs/candy-cane.svg';
      case SailSVGAsset.play:
        return 'assets/svgs/play.svg';
      case SailSVGAsset.folderHeart:
        return 'assets/svgs/folder-heart.svg';
      case SailSVGAsset.penOff:
        return 'assets/svgs/pen-off.svg';
      case SailSVGAsset.fileCheck:
        return 'assets/svgs/file-check.svg';
      case SailSVGAsset.leafyGreen:
        return 'assets/svgs/leafy-green.svg';
      case SailSVGAsset.tangent:
        return 'assets/svgs/tangent.svg';
      case SailSVGAsset.bookAudio:
        return 'assets/svgs/book-audio.svg';
      case SailSVGAsset.table:
        return 'assets/svgs/table.svg';
      case SailSVGAsset.split:
        return 'assets/svgs/split.svg';
      case SailSVGAsset.send:
        return 'assets/svgs/send.svg';
      case SailSVGAsset.barcode:
        return 'assets/svgs/barcode.svg';
      case SailSVGAsset.videotape:
        return 'assets/svgs/videotape.svg';
      case SailSVGAsset.scroll:
        return 'assets/svgs/scroll.svg';
      case SailSVGAsset.phoneCall:
        return 'assets/svgs/phone-call.svg';
      case SailSVGAsset.columns4:
        return 'assets/svgs/columns-4.svg';
      case SailSVGAsset.baggageClaim:
        return 'assets/svgs/baggage-claim.svg';
      case SailSVGAsset.circleArrowOutUpRight:
        return 'assets/svgs/circle-arrow-out-up-right.svg';
      case SailSVGAsset.radiation:
        return 'assets/svgs/radiation.svg';
      case SailSVGAsset.speaker:
        return 'assets/svgs/speaker.svg';
      case SailSVGAsset.userRoundSearch:
        return 'assets/svgs/user-round-search.svg';
      case SailSVGAsset.undoDot:
        return 'assets/svgs/undo-dot.svg';
      case SailSVGAsset.facebook:
        return 'assets/svgs/facebook.svg';
      case SailSVGAsset.codesandbox:
        return 'assets/svgs/codesandbox.svg';
      case SailSVGAsset.fileDown:
        return 'assets/svgs/file-down.svg';
      case SailSVGAsset.badgeCheck:
        return 'assets/svgs/badge-check.svg';
      case SailSVGAsset.baby:
        return 'assets/svgs/baby.svg';
      case SailSVGAsset.smartphoneCharging:
        return 'assets/svgs/smartphone-charging.svg';
      case SailSVGAsset.bookPlus:
        return 'assets/svgs/book-plus.svg';
      case SailSVGAsset.unplug:
        return 'assets/svgs/unplug.svg';
      case SailSVGAsset.heading3:
        return 'assets/svgs/heading-3.svg';
      case SailSVGAsset.bluetoothConnected:
        return 'assets/svgs/bluetooth-connected.svg';
      case SailSVGAsset.camera:
        return 'assets/svgs/camera.svg';
      case SailSVGAsset.link2:
        return 'assets/svgs/link-2.svg';
      case SailSVGAsset.printer:
        return 'assets/svgs/printer.svg';
      case SailSVGAsset.listCollapse:
        return 'assets/svgs/list-collapse.svg';
      case SailSVGAsset.workflow:
        return 'assets/svgs/workflow.svg';
      case SailSVGAsset.trees:
        return 'assets/svgs/trees.svg';
      case SailSVGAsset.panelLeftClose:
        return 'assets/svgs/panel-left-close.svg';
      case SailSVGAsset.gitGraph:
        return 'assets/svgs/git-graph.svg';
      case SailSVGAsset.redo:
        return 'assets/svgs/redo.svg';
      case SailSVGAsset.captionsOff:
        return 'assets/svgs/captions-off.svg';
      case SailSVGAsset.club:
        return 'assets/svgs/club.svg';
      case SailSVGAsset.folderMinus:
        return 'assets/svgs/folder-minus.svg';
      case SailSVGAsset.moveDiagonal2:
        return 'assets/svgs/move-diagonal-2.svg';
      case SailSVGAsset.combine:
        return 'assets/svgs/combine.svg';
      case SailSVGAsset.arrowUpRight:
        return 'assets/svgs/arrow-up-right.svg';
      case SailSVGAsset.truck:
        return 'assets/svgs/truck.svg';
      case SailSVGAsset.layoutPanelTop:
        return 'assets/svgs/layout-panel-top.svg';
      case SailSVGAsset.lifeBuoy:
        return 'assets/svgs/life-buoy.svg';
      case SailSVGAsset.userSearch:
        return 'assets/svgs/user-search.svg';
      case SailSVGAsset.squareUser:
        return 'assets/svgs/square-user.svg';
      case SailSVGAsset.tableColumnsSplit:
        return 'assets/svgs/table-columns-split.svg';
      case SailSVGAsset.betweenHorizontalStart:
        return 'assets/svgs/between-horizontal-start.svg';
      case SailSVGAsset.pickaxe:
        return 'assets/svgs/pickaxe.svg';
      case SailSVGAsset.packageX:
        return 'assets/svgs/package-x.svg';
      case SailSVGAsset.penTool:
        return 'assets/svgs/pen-tool.svg';
      case SailSVGAsset.alarmClockMinus:
        return 'assets/svgs/alarm-clock-minus.svg';
      case SailSVGAsset.panelsLeftBottom:
        return 'assets/svgs/panels-left-bottom.svg';
      case SailSVGAsset.circleGauge:
        return 'assets/svgs/circle-gauge.svg';
      case SailSVGAsset.folderCog:
        return 'assets/svgs/folder-cog.svg';
      case SailSVGAsset.atSign:
        return 'assets/svgs/at-sign.svg';
      case SailSVGAsset.rotateCcwSquare:
        return 'assets/svgs/rotate-ccw-square.svg';
      case SailSVGAsset.circleArrowRight:
        return 'assets/svgs/circle-arrow-right.svg';
      case SailSVGAsset.shieldAlert:
        return 'assets/svgs/shield-alert.svg';
      case SailSVGAsset.mapPinOff:
        return 'assets/svgs/map-pin-off.svg';
      case SailSVGAsset.listRestart:
        return 'assets/svgs/list-restart.svg';
      case SailSVGAsset.handMetal:
        return 'assets/svgs/hand-metal.svg';
      case SailSVGAsset.egg:
        return 'assets/svgs/egg.svg';
      case SailSVGAsset.carTaxiFront:
        return 'assets/svgs/car-taxi-front.svg';
      case SailSVGAsset.squareMousePointer:
        return 'assets/svgs/square-mouse-pointer.svg';
      case SailSVGAsset.monitorX:
        return 'assets/svgs/monitor-x.svg';
      case SailSVGAsset.squareTerminal:
        return 'assets/svgs/square-terminal.svg';
      case SailSVGAsset.grid2x2Check:
        return 'assets/svgs/grid-2x2-check.svg';
      case SailSVGAsset.bus:
        return 'assets/svgs/bus.svg';
      case SailSVGAsset.filePenLine:
        return 'assets/svgs/file-pen-line.svg';
      case SailSVGAsset.bookHeart:
        return 'assets/svgs/book-heart.svg';
      case SailSVGAsset.infinity:
        return 'assets/svgs/infinity.svg';
      case SailSVGAsset.gem:
        return 'assets/svgs/gem.svg';
      case SailSVGAsset.filterX:
        return 'assets/svgs/filter-x.svg';
      case SailSVGAsset.gitCompare:
        return 'assets/svgs/git-compare.svg';
      case SailSVGAsset.receiptCent:
        return 'assets/svgs/receipt-cent.svg';
      case SailSVGAsset.feather:
        return 'assets/svgs/feather.svg';
      case SailSVGAsset.webhookOff:
        return 'assets/svgs/webhook-off.svg';
      case SailSVGAsset.trash:
        return 'assets/svgs/trash.svg';
      case SailSVGAsset.treePalm:
        return 'assets/svgs/tree-palm.svg';
      case SailSVGAsset.arrowDown10:
        return 'assets/svgs/arrow-down-1-0.svg';
      case SailSVGAsset.databaseBackup:
        return 'assets/svgs/database-backup.svg';
      case SailSVGAsset.armchair:
        return 'assets/svgs/armchair.svg';
      case SailSVGAsset.wifiOff:
        return 'assets/svgs/wifi-off.svg';
      case SailSVGAsset.userRound:
        return 'assets/svgs/user-round.svg';
      case SailSVGAsset.ungroup:
        return 'assets/svgs/ungroup.svg';
      case SailSVGAsset.bookLock:
        return 'assets/svgs/book-lock.svg';
      case SailSVGAsset.leaf:
        return 'assets/svgs/leaf.svg';
      case SailSVGAsset.arrowDownWideNarrow:
        return 'assets/svgs/arrow-down-wide-narrow.svg';
      case SailSVGAsset.network:
        return 'assets/svgs/network.svg';
      case SailSVGAsset.fileLock2:
        return 'assets/svgs/file-lock-2.svg';
      case SailSVGAsset.appWindowMac:
        return 'assets/svgs/app-window-mac.svg';
      case SailSVGAsset.arrowUpZA:
        return 'assets/svgs/arrow-up-z-a.svg';
      case SailSVGAsset.scanBarcode:
        return 'assets/svgs/scan-barcode.svg';
      case SailSVGAsset.cornerLeftDown:
        return 'assets/svgs/corner-left-down.svg';
      case SailSVGAsset.messageSquarePlus:
        return 'assets/svgs/message-square-plus.svg';
      case SailSVGAsset.folderClock:
        return 'assets/svgs/folder-clock.svg';
      case SailSVGAsset.paintbrushVertical:
        return 'assets/svgs/paintbrush-vertical.svg';
      case SailSVGAsset.dollarSign:
        return 'assets/svgs/dollar-sign.svg';
      case SailSVGAsset.triangleRight:
        return 'assets/svgs/triangle-right.svg';
      case SailSVGAsset.indianRupee:
        return 'assets/svgs/indian-rupee.svg';
      case SailSVGAsset.construction:
        return 'assets/svgs/construction.svg';
      case SailSVGAsset.circlePlus:
        return 'assets/svgs/circle-plus.svg';
      case SailSVGAsset.graduationCap:
        return 'assets/svgs/graduation-cap.svg';
      case SailSVGAsset.scanFace:
        return 'assets/svgs/scan-face.svg';
      case SailSVGAsset.fishSymbol:
        return 'assets/svgs/fish-symbol.svg';
      case SailSVGAsset.monitorSpeaker:
        return 'assets/svgs/monitor-speaker.svg';
      case SailSVGAsset.guitar:
        return 'assets/svgs/guitar.svg';
      case SailSVGAsset.star:
        return 'assets/svgs/star.svg';
      case SailSVGAsset.lockKeyholeOpen:
        return 'assets/svgs/lock-keyhole-open.svg';
      case SailSVGAsset.monitorCheck:
        return 'assets/svgs/monitor-check.svg';
      case SailSVGAsset.sandwich:
        return 'assets/svgs/sandwich.svg';
      case SailSVGAsset.chefHat:
        return 'assets/svgs/chef-hat.svg';
      case SailSVGAsset.heading6:
        return 'assets/svgs/heading-6.svg';
      case SailSVGAsset.cloudOff:
        return 'assets/svgs/cloud-off.svg';
      case SailSVGAsset.saveAll:
        return 'assets/svgs/save-all.svg';
      case SailSVGAsset.sun:
        return 'assets/svgs/sun.svg';
      case SailSVGAsset.wrench:
        return 'assets/svgs/wrench.svg';
      case SailSVGAsset.signalMedium:
        return 'assets/svgs/signal-medium.svg';
      case SailSVGAsset.grab:
        return 'assets/svgs/grab.svg';
      case SailSVGAsset.pyramid:
        return 'assets/svgs/pyramid.svg';
      case SailSVGAsset.bookMinus:
        return 'assets/svgs/book-minus.svg';
      case SailSVGAsset.gauge:
        return 'assets/svgs/gauge.svg';
      case SailSVGAsset.messageSquare:
        return 'assets/svgs/message-square.svg';
      case SailSVGAsset.bugPlay:
        return 'assets/svgs/bug-play.svg';
      case SailSVGAsset.bookX:
        return 'assets/svgs/book-x.svg';
      case SailSVGAsset.heading4:
        return 'assets/svgs/heading-4.svg';
      case SailSVGAsset.pizza:
        return 'assets/svgs/pizza.svg';
      case SailSVGAsset.unlink:
        return 'assets/svgs/unlink.svg';
      case SailSVGAsset.chevronsDownUp:
        return 'assets/svgs/chevrons-down-up.svg';
      case SailSVGAsset.bone:
        return 'assets/svgs/bone.svg';
      case SailSVGAsset.flashlightOff:
        return 'assets/svgs/flashlight-off.svg';
      case SailSVGAsset.fileJson2:
        return 'assets/svgs/file-json-2.svg';
      case SailSVGAsset.anchor:
        return 'assets/svgs/anchor.svg';
      case SailSVGAsset.hammer:
        return 'assets/svgs/hammer.svg';
      case SailSVGAsset.plug2:
        return 'assets/svgs/plug-2.svg';
      case SailSVGAsset.notebookPen:
        return 'assets/svgs/notebook-pen.svg';
      case SailSVGAsset.chevronsUp:
        return 'assets/svgs/chevrons-up.svg';
      case SailSVGAsset.columns3:
        return 'assets/svgs/columns-3.svg';
      case SailSVGAsset.moveHorizontal:
        return 'assets/svgs/move-horizontal.svg';
      case SailSVGAsset.highlighter:
        return 'assets/svgs/highlighter.svg';
      case SailSVGAsset.squareArrowUpRight:
        return 'assets/svgs/square-arrow-up-right.svg';
      case SailSVGAsset.tabletSmartphone:
        return 'assets/svgs/tablet-smartphone.svg';
      case SailSVGAsset.circleStop:
        return 'assets/svgs/circle-stop.svg';
      case SailSVGAsset.twitch:
        return 'assets/svgs/twitch.svg';
      case SailSVGAsset.banana:
        return 'assets/svgs/banana.svg';
      case SailSVGAsset.treeDeciduous:
        return 'assets/svgs/tree-deciduous.svg';
      case SailSVGAsset.folderLock:
        return 'assets/svgs/folder-lock.svg';
      case SailSVGAsset.locate:
        return 'assets/svgs/locate.svg';
      case SailSVGAsset.listMusic:
        return 'assets/svgs/list-music.svg';
      case SailSVGAsset.bug:
        return 'assets/svgs/bug.svg';
      case SailSVGAsset.panelTop:
        return 'assets/svgs/panel-top.svg';
      case SailSVGAsset.messageSquareCode:
        return 'assets/svgs/message-square-code.svg';
      case SailSVGAsset.mailOpen:
        return 'assets/svgs/mail-open.svg';
      case SailSVGAsset.youtube:
        return 'assets/svgs/youtube.svg';
      case SailSVGAsset.chevronsLeftRight:
        return 'assets/svgs/chevrons-left-right.svg';
      case SailSVGAsset.bookmarkPlus:
        return 'assets/svgs/bookmark-plus.svg';
      case SailSVGAsset.aArrowUp:
        return 'assets/svgs/a-arrow-up.svg';
      case SailSVGAsset.towerControl:
        return 'assets/svgs/tower-control.svg';
      case SailSVGAsset.bookUp:
        return 'assets/svgs/book-up.svg';
      case SailSVGAsset.pocketKnife:
        return 'assets/svgs/pocket-knife.svg';
      case SailSVGAsset.shovel:
        return 'assets/svgs/shovel.svg';
      case SailSVGAsset.compass:
        return 'assets/svgs/compass.svg';
      case SailSVGAsset.fileMinus2:
        return 'assets/svgs/file-minus-2.svg';
      case SailSVGAsset.alignHorizontalJustifyEnd:
        return 'assets/svgs/align-horizontal-justify-end.svg';
      case SailSVGAsset.serverCrash:
        return 'assets/svgs/server-crash.svg';
      case SailSVGAsset.trafficCone:
        return 'assets/svgs/traffic-cone.svg';
      case SailSVGAsset.planeTakeoff:
        return 'assets/svgs/plane-takeoff.svg';
      case SailSVGAsset.folderKanban:
        return 'assets/svgs/folder-kanban.svg';
      case SailSVGAsset.mailSearch:
        return 'assets/svgs/mail-search.svg';
      case SailSVGAsset.imageUp:
        return 'assets/svgs/image-up.svg';
      case SailSVGAsset.cloudMoon:
        return 'assets/svgs/cloud-moon.svg';
      case SailSVGAsset.columns2:
        return 'assets/svgs/columns-2.svg';
      case SailSVGAsset.warehouse:
        return 'assets/svgs/warehouse.svg';
      case SailSVGAsset.rotateCwSquare:
        return 'assets/svgs/rotate-cw-square.svg';
      case SailSVGAsset.squareFunction:
        return 'assets/svgs/square-function.svg';
      case SailSVGAsset.frame:
        return 'assets/svgs/frame.svg';
      case SailSVGAsset.creditCard:
        return 'assets/svgs/credit-card.svg';
      case SailSVGAsset.circleArrowDown:
        return 'assets/svgs/circle-arrow-down.svg';
      case SailSVGAsset.table2:
        return 'assets/svgs/table-2.svg';
      case SailSVGAsset.fileKey2:
        return 'assets/svgs/file-key-2.svg';
      case SailSVGAsset.copyleft:
        return 'assets/svgs/copyleft.svg';
      case SailSVGAsset.grid3x3:
        return 'assets/svgs/grid-3x3.svg';
      case SailSVGAsset.ticketX:
        return 'assets/svgs/ticket-x.svg';
      case SailSVGAsset.alignVerticalJustifyStart:
        return 'assets/svgs/align-vertical-justify-start.svg';
      case SailSVGAsset.heartOff:
        return 'assets/svgs/heart-off.svg';
      case SailSVGAsset.cylinder:
        return 'assets/svgs/cylinder.svg';
      case SailSVGAsset.computer:
        return 'assets/svgs/computer.svg';
      case SailSVGAsset.bookType:
        return 'assets/svgs/book-type.svg';
      case SailSVGAsset.pillBottle:
        return 'assets/svgs/pill-bottle.svg';
      case SailSVGAsset.heading5:
        return 'assets/svgs/heading-5.svg';
      case SailSVGAsset.thermometerSun:
        return 'assets/svgs/thermometer-sun.svg';
      case SailSVGAsset.badgeHelp:
        return 'assets/svgs/badge-help.svg';
      case SailSVGAsset.locateOff:
        return 'assets/svgs/locate-off.svg';
      case SailSVGAsset.replyAll:
        return 'assets/svgs/reply-all.svg';
      case SailSVGAsset.pencil:
        return 'assets/svgs/pencil.svg';
      case SailSVGAsset.cloudRain:
        return 'assets/svgs/cloud-rain.svg';
      case SailSVGAsset.sendToBack:
        return 'assets/svgs/send-to-back.svg';
      case SailSVGAsset.iconTabOperationStatuses:
        return 'assets/svgs/icon_tab_operation_statuses.svg';
      case SailSVGAsset.gitPullRequestClosed:
        return 'assets/svgs/git-pull-request-closed.svg';
      case SailSVGAsset.arrowBigRightDash:
        return 'assets/svgs/arrow-big-right-dash.svg';
      case SailSVGAsset.alignVerticalDistributeStart:
        return 'assets/svgs/align-vertical-distribute-start.svg';
      case SailSVGAsset.bookDown:
        return 'assets/svgs/book-down.svg';
      case SailSVGAsset.poundSterling:
        return 'assets/svgs/pound-sterling.svg';
      case SailSVGAsset.monitorUp:
        return 'assets/svgs/monitor-up.svg';
      case SailSVGAsset.beanOff:
        return 'assets/svgs/bean-off.svg';
      case SailSVGAsset.trash2:
        return 'assets/svgs/trash-2.svg';
      case SailSVGAsset.circleUser:
        return 'assets/svgs/circle-user.svg';
      case SailSVGAsset.skipBack:
        return 'assets/svgs/skip-back.svg';
      case SailSVGAsset.filePlus:
        return 'assets/svgs/file-plus.svg';
      case SailSVGAsset.scrollText:
        return 'assets/svgs/scroll-text.svg';
      case SailSVGAsset.ganttChart:
        return 'assets/svgs/gantt-chart.svg';
      case SailSVGAsset.diamond:
        return 'assets/svgs/diamond.svg';
      case SailSVGAsset.delete:
        return 'assets/svgs/delete.svg';
      case SailSVGAsset.command:
        return 'assets/svgs/command.svg';
      case SailSVGAsset.packageCheck:
        return 'assets/svgs/package-check.svg';
      case SailSVGAsset.alignCenterHorizontal:
        return 'assets/svgs/align-center-horizontal.svg';
      case SailSVGAsset.clock:
        return 'assets/svgs/clock.svg';
      case SailSVGAsset.bellRing:
        return 'assets/svgs/bell-ring.svg';
      case SailSVGAsset.removeFormatting:
        return 'assets/svgs/remove-formatting.svg';
      case SailSVGAsset.router:
        return 'assets/svgs/router.svg';
      case SailSVGAsset.footprints:
        return 'assets/svgs/footprints.svg';
      case SailSVGAsset.octagon:
        return 'assets/svgs/octagon.svg';
      case SailSVGAsset.arrowBigLeft:
        return 'assets/svgs/arrow-big-left.svg';
      case SailSVGAsset.tableRowsSplit:
        return 'assets/svgs/table-rows-split.svg';
      case SailSVGAsset.phone:
        return 'assets/svgs/phone.svg';
      case SailSVGAsset.circleX:
        return 'assets/svgs/circle-x.svg';
      case SailSVGAsset.landPlot:
        return 'assets/svgs/land-plot.svg';
      case SailSVGAsset.alignHorizontalJustifyCenter:
        return 'assets/svgs/align-horizontal-justify-center.svg';
      case SailSVGAsset.sunSnow:
        return 'assets/svgs/sun-snow.svg';
      case SailSVGAsset.imageOff:
        return 'assets/svgs/image-off.svg';
      case SailSVGAsset.umbrellaOff:
        return 'assets/svgs/umbrella-off.svg';
      case SailSVGAsset.arrowDownAZ:
        return 'assets/svgs/arrow-down-a-z.svg';
      case SailSVGAsset.panelLeftOpen:
        return 'assets/svgs/panel-left-open.svg';
      case SailSVGAsset.brainCircuit:
        return 'assets/svgs/brain-circuit.svg';
      case SailSVGAsset.moveVertical:
        return 'assets/svgs/move-vertical.svg';
      case SailSVGAsset.usersRound:
        return 'assets/svgs/users-round.svg';
      case SailSVGAsset.salad:
        return 'assets/svgs/salad.svg';
      case SailSVGAsset.dumbbell:
        return 'assets/svgs/dumbbell.svg';
      case SailSVGAsset.tractor:
        return 'assets/svgs/tractor.svg';
      case SailSVGAsset.waves:
        return 'assets/svgs/waves.svg';
      case SailSVGAsset.folderClosed:
        return 'assets/svgs/folder-closed.svg';
      case SailSVGAsset.eye:
        return 'assets/svgs/eye.svg';
      case SailSVGAsset.userRoundCog:
        return 'assets/svgs/user-round-cog.svg';
      case SailSVGAsset.indentIncrease:
        return 'assets/svgs/indent-increase.svg';
      case SailSVGAsset.mousePointerBan:
        return 'assets/svgs/mouse-pointer-ban.svg';
      case SailSVGAsset.badgeAlert:
        return 'assets/svgs/badge-alert.svg';
      case SailSVGAsset.serverCog:
        return 'assets/svgs/server-cog.svg';
      case SailSVGAsset.pipette:
        return 'assets/svgs/pipette.svg';
      case SailSVGAsset.phoneOff:
        return 'assets/svgs/phone-off.svg';
      case SailSVGAsset.flower:
        return 'assets/svgs/flower.svg';
      case SailSVGAsset.banknote:
        return 'assets/svgs/banknote.svg';
      case SailSVGAsset.sprout:
        return 'assets/svgs/sprout.svg';
      case SailSVGAsset.brickWall:
        return 'assets/svgs/brick-wall.svg';
      case SailSVGAsset.copyCheck:
        return 'assets/svgs/copy-check.svg';
      case SailSVGAsset.rectangleVertical:
        return 'assets/svgs/rectangle-vertical.svg';
      case SailSVGAsset.pill:
        return 'assets/svgs/pill.svg';
      case SailSVGAsset.codepen:
        return 'assets/svgs/codepen.svg';
      case SailSVGAsset.dribbble:
        return 'assets/svgs/dribbble.svg';
      case SailSVGAsset.messageCirclePlus:
        return 'assets/svgs/message-circle-plus.svg';
      case SailSVGAsset.axe:
        return 'assets/svgs/axe.svg';
      case SailSVGAsset.squarePlus:
        return 'assets/svgs/square-plus.svg';
      case SailSVGAsset.gift:
        return 'assets/svgs/gift.svg';
      case SailSVGAsset.receiptRussianRuble:
        return 'assets/svgs/receipt-russian-ruble.svg';
      case SailSVGAsset.packagePlus:
        return 'assets/svgs/package-plus.svg';
      case SailSVGAsset.externalLink:
        return 'assets/svgs/external-link.svg';
      case SailSVGAsset.lineChart:
        return 'assets/svgs/line-chart.svg';
      case SailSVGAsset.currency:
        return 'assets/svgs/currency.svg';
      case SailSVGAsset.wand:
        return 'assets/svgs/wand.svg';
      case SailSVGAsset.fileMusic:
        return 'assets/svgs/file-music.svg';
      case SailSVGAsset.car:
        return 'assets/svgs/car.svg';
      case SailSVGAsset.zap:
        return 'assets/svgs/zap.svg';
      case SailSVGAsset.trello:
        return 'assets/svgs/trello.svg';
      case SailSVGAsset.listChecks:
        return 'assets/svgs/list-checks.svg';
      case SailSVGAsset.messageSquareReply:
        return 'assets/svgs/message-square-reply.svg';
      case SailSVGAsset.badgeX:
        return 'assets/svgs/badge-x.svg';
      case SailSVGAsset.building2:
        return 'assets/svgs/building-2.svg';
      case SailSVGAsset.moonStar:
        return 'assets/svgs/moon-star.svg';
      case SailSVGAsset.clock1:
        return 'assets/svgs/clock-1.svg';
      case SailSVGAsset.cigaretteOff:
        return 'assets/svgs/cigarette-off.svg';
      case SailSVGAsset.binary:
        return 'assets/svgs/binary.svg';
      case SailSVGAsset.chevronLast:
        return 'assets/svgs/chevron-last.svg';
      case SailSVGAsset.pointerOff:
        return 'assets/svgs/pointer-off.svg';
      case SailSVGAsset.mousePointer2:
        return 'assets/svgs/mouse-pointer-2.svg';
      case SailSVGAsset.packageSearch:
        return 'assets/svgs/package-search.svg';
      case SailSVGAsset.micOff:
        return 'assets/svgs/mic-off.svg';
      case SailSVGAsset.lampDesk:
        return 'assets/svgs/lamp-desk.svg';
      case SailSVGAsset.share:
        return 'assets/svgs/share.svg';
      case SailSVGAsset.circleParkingOff:
        return 'assets/svgs/circle-parking-off.svg';
      case SailSVGAsset.tags:
        return 'assets/svgs/tags.svg';
      case SailSVGAsset.squareBottomDashedScissors:
        return 'assets/svgs/square-bottom-dashed-scissors.svg';
      case SailSVGAsset.iconTabBmm:
        return 'assets/svgs/icon_tab_bmm.svg';
      case SailSVGAsset.album:
        return 'assets/svgs/album.svg';
      case SailSVGAsset.keyRound:
        return 'assets/svgs/key-round.svg';
      case SailSVGAsset.squareCode:
        return 'assets/svgs/square-code.svg';
      case SailSVGAsset.folderSearch2:
        return 'assets/svgs/folder-search-2.svg';
      case SailSVGAsset.arrowUp:
        return 'assets/svgs/arrow-up.svg';
      case SailSVGAsset.circleArrowOutUpLeft:
        return 'assets/svgs/circle-arrow-out-up-left.svg';
      case SailSVGAsset.microscope:
        return 'assets/svgs/microscope.svg';
      case SailSVGAsset.testTube:
        return 'assets/svgs/test-tube.svg';
      case SailSVGAsset.bellOff:
        return 'assets/svgs/bell-off.svg';
      case SailSVGAsset.linkedin:
        return 'assets/svgs/linkedin.svg';
      case SailSVGAsset.arrowDownNarrowWide:
        return 'assets/svgs/arrow-down-narrow-wide.svg';
      case SailSVGAsset.clock3:
        return 'assets/svgs/clock-3.svg';
      case SailSVGAsset.panelRight:
        return 'assets/svgs/panel-right.svg';
      case SailSVGAsset.drum:
        return 'assets/svgs/drum.svg';
      case SailSVGAsset.view:
        return 'assets/svgs/view.svg';
      case SailSVGAsset.music2:
        return 'assets/svgs/music-2.svg';
      case SailSVGAsset.wrapText:
        return 'assets/svgs/wrap-text.svg';
      case SailSVGAsset.gitCompareArrows:
        return 'assets/svgs/git-compare-arrows.svg';
      case SailSVGAsset.calendarMinus:
        return 'assets/svgs/calendar-minus.svg';
      case SailSVGAsset.bookImage:
        return 'assets/svgs/book-image.svg';
      case SailSVGAsset.fileVolume2:
        return 'assets/svgs/file-volume-2.svg';
      case SailSVGAsset.userRoundX:
        return 'assets/svgs/user-round-x.svg';
      case SailSVGAsset.undo:
        return 'assets/svgs/undo.svg';
      case SailSVGAsset.video:
        return 'assets/svgs/video.svg';
      case SailSVGAsset.circleEllipsis:
        return 'assets/svgs/circle-ellipsis.svg';
      case SailSVGAsset.activity:
        return 'assets/svgs/activity.svg';
      case SailSVGAsset.pencilLine:
        return 'assets/svgs/pencil-line.svg';
      case SailSVGAsset.personStanding:
        return 'assets/svgs/person-standing.svg';
      case SailSVGAsset.twitter:
        return 'assets/svgs/twitter.svg';
      case SailSVGAsset.mapPin:
        return 'assets/svgs/map-pin.svg';
      case SailSVGAsset.folderInput:
        return 'assets/svgs/folder-input.svg';
      case SailSVGAsset.filter:
        return 'assets/svgs/filter.svg';
      case SailSVGAsset.lightbulbOff:
        return 'assets/svgs/lightbulb-off.svg';
      case SailSVGAsset.phoneIncoming:
        return 'assets/svgs/phone-incoming.svg';
      case SailSVGAsset.refrigerator:
        return 'assets/svgs/refrigerator.svg';
      case SailSVGAsset.italic:
        return 'assets/svgs/italic.svg';
      case SailSVGAsset.listEnd:
        return 'assets/svgs/list-end.svg';
      case SailSVGAsset.handshake:
        return 'assets/svgs/handshake.svg';
      case SailSVGAsset.chevronsLeft:
        return 'assets/svgs/chevrons-left.svg';
      case SailSVGAsset.rows2:
        return 'assets/svgs/rows-2.svg';
      case SailSVGAsset.mailX:
        return 'assets/svgs/mail-x.svg';
      case SailSVGAsset.medal:
        return 'assets/svgs/medal.svg';
      case SailSVGAsset.messageCircleCode:
        return 'assets/svgs/message-circle-code.svg';
      case SailSVGAsset.calendar:
        return 'assets/svgs/calendar.svg';
      case SailSVGAsset.inspectionPanel:
        return 'assets/svgs/inspection-panel.svg';
      case SailSVGAsset.notepadText:
        return 'assets/svgs/notepad-text.svg';
      case SailSVGAsset.messageCircleX:
        return 'assets/svgs/message-circle-x.svg';
      case SailSVGAsset.arrowRightFromLine:
        return 'assets/svgs/arrow-right-from-line.svg';
      case SailSVGAsset.globe:
        return 'assets/svgs/globe.svg';
      case SailSVGAsset.arrowLeft:
        return 'assets/svgs/arrow-left.svg';
      case SailSVGAsset.paintbrush:
        return 'assets/svgs/paintbrush.svg';
      case SailSVGAsset.rows3:
        return 'assets/svgs/rows-3.svg';
      case SailSVGAsset.alignCenter:
        return 'assets/svgs/align-center.svg';
      case SailSVGAsset.badgeSwissFranc:
        return 'assets/svgs/badge-swiss-franc.svg';
      case SailSVGAsset.cross:
        return 'assets/svgs/cross.svg';
      case SailSVGAsset.squareMinus:
        return 'assets/svgs/square-minus.svg';
      case SailSVGAsset.university:
        return 'assets/svgs/university.svg';
      case SailSVGAsset.route:
        return 'assets/svgs/route.svg';
      case SailSVGAsset.circleArrowUp:
        return 'assets/svgs/circle-arrow-up.svg';
      case SailSVGAsset.diameter:
        return 'assets/svgs/diameter.svg';
      case SailSVGAsset.pcCase:
        return 'assets/svgs/pc-case.svg';
      case SailSVGAsset.ellipsis:
        return 'assets/svgs/ellipsis.svg';
      case SailSVGAsset.calendarHeart:
        return 'assets/svgs/calendar-heart.svg';
      case SailSVGAsset.bookHeadphones:
        return 'assets/svgs/book-headphones.svg';
      case SailSVGAsset.arrowDownRight:
        return 'assets/svgs/arrow-down-right.svg';
      case SailSVGAsset.fileBox:
        return 'assets/svgs/file-box.svg';
      case SailSVGAsset.pawPrint:
        return 'assets/svgs/paw-print.svg';
      case SailSVGAsset.laptop:
        return 'assets/svgs/laptop.svg';
      case SailSVGAsset.powerOff:
        return 'assets/svgs/power-off.svg';
      case SailSVGAsset.redoDot:
        return 'assets/svgs/redo-dot.svg';
      case SailSVGAsset.axis3d:
        return 'assets/svgs/axis-3d.svg';
      case SailSVGAsset.arrowBigUp:
        return 'assets/svgs/arrow-big-up.svg';
      case SailSVGAsset.framer:
        return 'assets/svgs/framer.svg';
      case SailSVGAsset.keyboardOff:
        return 'assets/svgs/keyboard-off.svg';
      case SailSVGAsset.mountain:
        return 'assets/svgs/mountain.svg';
      case SailSVGAsset.stretchHorizontal:
        return 'assets/svgs/stretch-horizontal.svg';
      case SailSVGAsset.bellDot:
        return 'assets/svgs/bell-dot.svg';
      case SailSVGAsset.clipboardX:
        return 'assets/svgs/clipboard-x.svg';
      case SailSVGAsset.folderDown:
        return 'assets/svgs/folder-down.svg';
      case SailSVGAsset.shieldQuestion:
        return 'assets/svgs/shield-question.svg';
      case SailSVGAsset.panelBottomDashed:
        return 'assets/svgs/panel-bottom-dashed.svg';
      case SailSVGAsset.volumeX:
        return 'assets/svgs/volume-x.svg';
      case SailSVGAsset.music3:
        return 'assets/svgs/music-3.svg';
      case SailSVGAsset.copySlash:
        return 'assets/svgs/copy-slash.svg';
      case SailSVGAsset.fileCode:
        return 'assets/svgs/file-code.svg';
      case SailSVGAsset.moveLeft:
        return 'assets/svgs/move-left.svg';
      case SailSVGAsset.slack:
        return 'assets/svgs/slack.svg';
      case SailSVGAsset.circleDashed:
        return 'assets/svgs/circle-dashed.svg';
      case SailSVGAsset.clock2:
        return 'assets/svgs/clock-2.svg';
      case SailSVGAsset.userRoundMinus:
        return 'assets/svgs/user-round-minus.svg';
      case SailSVGAsset.scissorsLineDashed:
        return 'assets/svgs/scissors-line-dashed.svg';
      case SailSVGAsset.fileOutput:
        return 'assets/svgs/file-output.svg';
      case SailSVGAsset.cloud:
        return 'assets/svgs/cloud.svg';
      case SailSVGAsset.hopOff:
        return 'assets/svgs/hop-off.svg';
      case SailSVGAsset.clock11:
        return 'assets/svgs/clock-11.svg';
      case SailSVGAsset.shuffle:
        return 'assets/svgs/shuffle.svg';
      case SailSVGAsset.quote:
        return 'assets/svgs/quote.svg';
      case SailSVGAsset.anvil:
        return 'assets/svgs/anvil.svg';
      case SailSVGAsset.washingMachine:
        return 'assets/svgs/washing-machine.svg';
      case SailSVGAsset.gripVertical:
        return 'assets/svgs/grip-vertical.svg';
      case SailSVGAsset.clock6:
        return 'assets/svgs/clock-6.svg';
      case SailSVGAsset.drill:
        return 'assets/svgs/drill.svg';
      case SailSVGAsset.plugZap2:
        return 'assets/svgs/plug-zap-2.svg';
      case SailSVGAsset.alignHorizontalDistributeStart:
        return 'assets/svgs/align-horizontal-distribute-start.svg';
      case SailSVGAsset.fileType:
        return 'assets/svgs/file-type.svg';
      case SailSVGAsset.rewind:
        return 'assets/svgs/rewind.svg';
      case SailSVGAsset.wineOff:
        return 'assets/svgs/wine-off.svg';
      case SailSVGAsset.upload:
        return 'assets/svgs/upload.svg';
      case SailSVGAsset.trendingDown:
        return 'assets/svgs/trending-down.svg';
      case SailSVGAsset.bookmarkCheck:
        return 'assets/svgs/bookmark-check.svg';
      case SailSVGAsset.foldVertical:
        return 'assets/svgs/fold-vertical.svg';
      case SailSVGAsset.calendarX:
        return 'assets/svgs/calendar-x.svg';
      case SailSVGAsset.pause:
        return 'assets/svgs/pause.svg';
      case SailSVGAsset.radical:
        return 'assets/svgs/radical.svg';
      case SailSVGAsset.arrowBigUpDash:
        return 'assets/svgs/arrow-big-up-dash.svg';
      case SailSVGAsset.folderKey:
        return 'assets/svgs/folder-key.svg';
      case SailSVGAsset.grid2x2:
        return 'assets/svgs/grid-2x2.svg';
      case SailSVGAsset.cloudHail:
        return 'assets/svgs/cloud-hail.svg';
      case SailSVGAsset.searchX:
        return 'assets/svgs/search-x.svg';
      case SailSVGAsset.cloudy:
        return 'assets/svgs/cloudy.svg';
      case SailSVGAsset.replace:
        return 'assets/svgs/replace.svg';
      case SailSVGAsset.forward:
        return 'assets/svgs/forward.svg';
      case SailSVGAsset.mountainSnow:
        return 'assets/svgs/mountain-snow.svg';
      case SailSVGAsset.indentDecrease:
        return 'assets/svgs/indent-decrease.svg';
      case SailSVGAsset.circleMinus:
        return 'assets/svgs/circle-minus.svg';
      case SailSVGAsset.dices:
        return 'assets/svgs/dices.svg';
      case SailSVGAsset.blend:
        return 'assets/svgs/blend.svg';
      case SailSVGAsset.bookmark:
        return 'assets/svgs/bookmark.svg';
      case SailSVGAsset.braces:
        return 'assets/svgs/braces.svg';
      case SailSVGAsset.rocket:
        return 'assets/svgs/rocket.svg';
      case SailSVGAsset.circleDot:
        return 'assets/svgs/circle-dot.svg';
      case SailSVGAsset.moveRight:
        return 'assets/svgs/move-right.svg';
      case SailSVGAsset.drama:
        return 'assets/svgs/drama.svg';
      case SailSVGAsset.asterisk:
        return 'assets/svgs/asterisk.svg';
      case SailSVGAsset.userCheck:
        return 'assets/svgs/user-check.svg';
      case SailSVGAsset.calendarClock:
        return 'assets/svgs/calendar-clock.svg';
      case SailSVGAsset.fishOff:
        return 'assets/svgs/fish-off.svg';
      case SailSVGAsset.folderSearch:
        return 'assets/svgs/folder-search.svg';
      case SailSVGAsset.folderPen:
        return 'assets/svgs/folder-pen.svg';
      case SailSVGAsset.cloudSunRain:
        return 'assets/svgs/cloud-sun-rain.svg';
      case SailSVGAsset.gitPullRequestCreate:
        return 'assets/svgs/git-pull-request-create.svg';
      case SailSVGAsset.tablet:
        return 'assets/svgs/tablet.svg';
      case SailSVGAsset.mailCheck:
        return 'assets/svgs/mail-check.svg';
      case SailSVGAsset.alignVerticalJustifyCenter:
        return 'assets/svgs/align-vertical-justify-center.svg';
      case SailSVGAsset.fileDiff:
        return 'assets/svgs/file-diff.svg';
      case SailSVGAsset.monitorDot:
        return 'assets/svgs/monitor-dot.svg';
      case SailSVGAsset.ticketSlash:
        return 'assets/svgs/ticket-slash.svg';
      case SailSVGAsset.alignHorizontalSpaceBetween:
        return 'assets/svgs/align-horizontal-space-between.svg';
      case SailSVGAsset.webhook:
        return 'assets/svgs/webhook.svg';
      case SailSVGAsset.diamondPercent:
        return 'assets/svgs/diamond-percent.svg';
      case SailSVGAsset.folderOpenDot:
        return 'assets/svgs/folder-open-dot.svg';
      case SailSVGAsset.arrowLeftRight:
        return 'assets/svgs/arrow-left-right.svg';
      case SailSVGAsset.codeXml:
        return 'assets/svgs/code-xml.svg';
      case SailSVGAsset.cloudDownload:
        return 'assets/svgs/cloud-download.svg';
      case SailSVGAsset.utilityPole:
        return 'assets/svgs/utility-pole.svg';
      case SailSVGAsset.signalZero:
        return 'assets/svgs/signal-zero.svg';
      case SailSVGAsset.bookUp2:
        return 'assets/svgs/book-up-2.svg';
      case SailSVGAsset.monitorOff:
        return 'assets/svgs/monitor-off.svg';
      case SailSVGAsset.ear:
        return 'assets/svgs/ear.svg';
      case SailSVGAsset.spellCheck:
        return 'assets/svgs/spell-check.svg';
      case SailSVGAsset.fileTerminal:
        return 'assets/svgs/file-terminal.svg';
      case SailSVGAsset.flame:
        return 'assets/svgs/flame.svg';
      case SailSVGAsset.iconTabMeltCast:
        return 'assets/svgs/icon_tab_melt_cast.svg';
      case SailSVGAsset.galleryHorizontalEnd:
        return 'assets/svgs/gallery-horizontal-end.svg';
      case SailSVGAsset.nutOff:
        return 'assets/svgs/nut-off.svg';
      case SailSVGAsset.component:
        return 'assets/svgs/component.svg';
      case SailSVGAsset.circleOff:
        return 'assets/svgs/circle-off.svg';
      case SailSVGAsset.fileSearch2:
        return 'assets/svgs/file-search-2.svg';
      case SailSVGAsset.alignStartHorizontal:
        return 'assets/svgs/align-start-horizontal.svg';
      case SailSVGAsset.locateFixed:
        return 'assets/svgs/locate-fixed.svg';
      case SailSVGAsset.lockOpen:
        return 'assets/svgs/lock-open.svg';
      case SailSVGAsset.loaderPinwheel:
        return 'assets/svgs/loader-pinwheel.svg';
      case SailSVGAsset.atom:
        return 'assets/svgs/atom.svg';
      case SailSVGAsset.cat:
        return 'assets/svgs/cat.svg';
      case SailSVGAsset.cloudCog:
        return 'assets/svgs/cloud-cog.svg';
      case SailSVGAsset.sword:
        return 'assets/svgs/sword.svg';
      case SailSVGAsset.squarePilcrow:
        return 'assets/svgs/square-pilcrow.svg';
      case SailSVGAsset.squirrel:
        return 'assets/svgs/squirrel.svg';
      case SailSVGAsset.menu:
        return 'assets/svgs/menu.svg';
      case SailSVGAsset.pinOff:
        return 'assets/svgs/pin-off.svg';
      case SailSVGAsset.lampCeiling:
        return 'assets/svgs/lamp-ceiling.svg';
      case SailSVGAsset.folderDot:
        return 'assets/svgs/folder-dot.svg';
      case SailSVGAsset.utensilsCrossed:
        return 'assets/svgs/utensils-crossed.svg';
      case SailSVGAsset.ratio:
        return 'assets/svgs/ratio.svg';
      case SailSVGAsset.squareArrowDownLeft:
        return 'assets/svgs/square-arrow-down-left.svg';
      case SailSVGAsset.grid2x2X:
        return 'assets/svgs/grid-2x2-x.svg';
      case SailSVGAsset.octagonAlert:
        return 'assets/svgs/octagon-alert.svg';
      case SailSVGAsset.galleryVertical:
        return 'assets/svgs/gallery-vertical.svg';
      case SailSVGAsset.imageMinus:
        return 'assets/svgs/image-minus.svg';
      case SailSVGAsset.clock7:
        return 'assets/svgs/clock-7.svg';
      case SailSVGAsset.arrowRightToLine:
        return 'assets/svgs/arrow-right-to-line.svg';
      case SailSVGAsset.aArrowDown:
        return 'assets/svgs/a-arrow-down.svg';
      case SailSVGAsset.merge:
        return 'assets/svgs/merge.svg';
      case SailSVGAsset.mapPinned:
        return 'assets/svgs/map-pinned.svg';
      case SailSVGAsset.squarePi:
        return 'assets/svgs/square-pi.svg';
      case SailSVGAsset.alignHorizontalSpaceAround:
        return 'assets/svgs/align-horizontal-space-around.svg';
      case SailSVGAsset.chrome:
        return 'assets/svgs/chrome.svg';
      case SailSVGAsset.stickyNote:
        return 'assets/svgs/sticky-note.svg';
      case SailSVGAsset.ticketPlus:
        return 'assets/svgs/ticket-plus.svg';
      case SailSVGAsset.shoppingCart:
        return 'assets/svgs/shopping-cart.svg';
      case SailSVGAsset.copyX:
        return 'assets/svgs/copy-x.svg';
      case SailSVGAsset.calculator:
        return 'assets/svgs/calculator.svg';
      case SailSVGAsset.clock10:
        return 'assets/svgs/clock-10.svg';
      case SailSVGAsset.trainFrontTunnel:
        return 'assets/svgs/train-front-tunnel.svg';
      case SailSVGAsset.clock12:
        return 'assets/svgs/clock-12.svg';
      case SailSVGAsset.apple:
        return 'assets/svgs/apple.svg';
      case SailSVGAsset.circleChevronLeft:
        return 'assets/svgs/circle-chevron-left.svg';
      case SailSVGAsset.mouse:
        return 'assets/svgs/mouse.svg';
      case SailSVGAsset.flaskConical:
        return 'assets/svgs/flask-conical.svg';
      case SailSVGAsset.pictureInPicture2:
        return 'assets/svgs/picture-in-picture-2.svg';
      case SailSVGAsset.pentagon:
        return 'assets/svgs/pentagon.svg';
      case SailSVGAsset.diamondMinus:
        return 'assets/svgs/diamond-minus.svg';
      case SailSVGAsset.shieldCheck:
        return 'assets/svgs/shield-check.svg';
      case SailSVGAsset.arrowDown01:
        return 'assets/svgs/arrow-down-0-1.svg';
      case SailSVGAsset.messageCircleReply:
        return 'assets/svgs/message-circle-reply.svg';
      case SailSVGAsset.circlePause:
        return 'assets/svgs/circle-pause.svg';
      case SailSVGAsset.mails:
        return 'assets/svgs/mails.svg';
      case SailSVGAsset.clock5:
        return 'assets/svgs/clock-5.svg';
      case SailSVGAsset.rectangleHorizontal:
        return 'assets/svgs/rectangle-horizontal.svg';
      case SailSVGAsset.shoppingBasket:
        return 'assets/svgs/shopping-basket.svg';
      case SailSVGAsset.listFilter:
        return 'assets/svgs/list-filter.svg';
      case SailSVGAsset.receiptText:
        return 'assets/svgs/receipt-text.svg';
      case SailSVGAsset.music4:
        return 'assets/svgs/music-4.svg';
      case SailSVGAsset.bookUser:
        return 'assets/svgs/book-user.svg';
      case SailSVGAsset.shieldBan:
        return 'assets/svgs/shield-ban.svg';
      case SailSVGAsset.arrowDownToDot:
        return 'assets/svgs/arrow-down-to-dot.svg';
      case SailSVGAsset.building:
        return 'assets/svgs/building.svg';
      case SailSVGAsset.clipboardCopy:
        return 'assets/svgs/clipboard-copy.svg';
      case SailSVGAsset.angry:
        return 'assets/svgs/angry.svg';
      case SailSVGAsset.lollipop:
        return 'assets/svgs/lollipop.svg';
      case SailSVGAsset.betweenVerticalEnd:
        return 'assets/svgs/between-vertical-end.svg';
      case SailSVGAsset.history:
        return 'assets/svgs/history.svg';
      case SailSVGAsset.gavel:
        return 'assets/svgs/gavel.svg';
      case SailSVGAsset.folder:
        return 'assets/svgs/folder.svg';
      case SailSVGAsset.draftingCompass:
        return 'assets/svgs/drafting-compass.svg';
      case SailSVGAsset.alignHorizontalDistributeCenter:
        return 'assets/svgs/align-horizontal-distribute-center.svg';
      case SailSVGAsset.fileLock:
        return 'assets/svgs/file-lock.svg';
      case SailSVGAsset.layers2:
        return 'assets/svgs/layers-2.svg';
      case SailSVGAsset.users:
        return 'assets/svgs/users.svg';
      case SailSVGAsset.boomBox:
        return 'assets/svgs/boom-box.svg';
      case SailSVGAsset.slice:
        return 'assets/svgs/slice.svg';
      case SailSVGAsset.folderGit:
        return 'assets/svgs/folder-git.svg';
      case SailSVGAsset.fingerprint:
        return 'assets/svgs/fingerprint.svg';
      case SailSVGAsset.flagOff:
        return 'assets/svgs/flag-off.svg';
      case SailSVGAsset.micVocal:
        return 'assets/svgs/mic-vocal.svg';
      case SailSVGAsset.cornerDownLeft:
        return 'assets/svgs/corner-down-left.svg';
      case SailSVGAsset.fileAxis3d:
        return 'assets/svgs/file-axis-3d.svg';
      case SailSVGAsset.bookOpenText:
        return 'assets/svgs/book-open-text.svg';
      case SailSVGAsset.timer:
        return 'assets/svgs/timer.svg';
      case SailSVGAsset.gamepad:
        return 'assets/svgs/gamepad.svg';
      case SailSVGAsset.gitCommitHorizontal:
        return 'assets/svgs/git-commit-horizontal.svg';
      case SailSVGAsset.monitor:
        return 'assets/svgs/monitor.svg';
      case SailSVGAsset.clipboardCheck:
        return 'assets/svgs/clipboard-check.svg';
      case SailSVGAsset.unlink2:
        return 'assets/svgs/unlink-2.svg';
      case SailSVGAsset.squareArrowOutDownRight:
        return 'assets/svgs/square-arrow-out-down-right.svg';
      case SailSVGAsset.minus:
        return 'assets/svgs/minus.svg';
      case SailSVGAsset.heartPulse:
        return 'assets/svgs/heart-pulse.svg';
      case SailSVGAsset.rows4:
        return 'assets/svgs/rows-4.svg';
      case SailSVGAsset.heartHandshake:
        return 'assets/svgs/heart-handshake.svg';
      case SailSVGAsset.bedDouble:
        return 'assets/svgs/bed-double.svg';
      case SailSVGAsset.textSearch:
        return 'assets/svgs/text-search.svg';
      case SailSVGAsset.audioWaveform:
        return 'assets/svgs/audio-waveform.svg';
      case SailSVGAsset.navigation2:
        return 'assets/svgs/navigation-2.svg';
      case SailSVGAsset.paintBucket:
        return 'assets/svgs/paint-bucket.svg';
      case SailSVGAsset.chevronLeft:
        return 'assets/svgs/chevron-left.svg';
      case SailSVGAsset.moveUp:
        return 'assets/svgs/move-up.svg';
      case SailSVGAsset.film:
        return 'assets/svgs/film.svg';
      case SailSVGAsset.moon:
        return 'assets/svgs/moon.svg';
      case SailSVGAsset.squareArrowLeft:
        return 'assets/svgs/square-arrow-left.svg';
      case SailSVGAsset.panelBottomClose:
        return 'assets/svgs/panel-bottom-close.svg';
      case SailSVGAsset.weight:
        return 'assets/svgs/weight.svg';
      case SailSVGAsset.shieldOff:
        return 'assets/svgs/shield-off.svg';
      case SailSVGAsset.layers3:
        return 'assets/svgs/layers-3.svg';
      case SailSVGAsset.scaling:
        return 'assets/svgs/scaling.svg';
      case SailSVGAsset.cable:
        return 'assets/svgs/cable.svg';
      case SailSVGAsset.accessibility:
        return 'assets/svgs/accessibility.svg';
      case SailSVGAsset.moveUpRight:
        return 'assets/svgs/move-up-right.svg';
      case SailSVGAsset.walletCards:
        return 'assets/svgs/wallet-cards.svg';
      case SailSVGAsset.busFront:
        return 'assets/svgs/bus-front.svg';
      case SailSVGAsset.lampWallDown:
        return 'assets/svgs/lamp-wall-down.svg';
      case SailSVGAsset.mousePointer:
        return 'assets/svgs/mouse-pointer.svg';
      case SailSVGAsset.fileJson:
        return 'assets/svgs/file-json.svg';
      case SailSVGAsset.trainFront:
        return 'assets/svgs/train-front.svg';
      case SailSVGAsset.calendarMinus2:
        return 'assets/svgs/calendar-minus-2.svg';
      case SailSVGAsset.ribbon:
        return 'assets/svgs/ribbon.svg';
      case SailSVGAsset.squareStack:
        return 'assets/svgs/square-stack.svg';
      case SailSVGAsset.flipHorizontal:
        return 'assets/svgs/flip-horizontal.svg';
      case SailSVGAsset.galleryHorizontal:
        return 'assets/svgs/gallery-horizontal.svg';
      case SailSVGAsset.notebook:
        return 'assets/svgs/notebook.svg';
      case SailSVGAsset.stamp:
        return 'assets/svgs/stamp.svg';
      case SailSVGAsset.squareSplitHorizontal:
        return 'assets/svgs/square-split-horizontal.svg';
      case SailSVGAsset.arrowUpDown:
        return 'assets/svgs/arrow-up-down.svg';
      case SailSVGAsset.screenShare:
        return 'assets/svgs/screen-share.svg';
      case SailSVGAsset.calendarDays:
        return 'assets/svgs/calendar-days.svg';
      case SailSVGAsset.alignLeft:
        return 'assets/svgs/align-left.svg';
      case SailSVGAsset.separatorHorizontal:
        return 'assets/svgs/separator-horizontal.svg';
      case SailSVGAsset.ferrisWheel:
        return 'assets/svgs/ferris-wheel.svg';
      case SailSVGAsset.sofa:
        return 'assets/svgs/sofa.svg';
      case SailSVGAsset.clock4:
        return 'assets/svgs/clock-4.svg';
      case SailSVGAsset.ticketCheck:
        return 'assets/svgs/ticket-check.svg';
      case SailSVGAsset.cherry:
        return 'assets/svgs/cherry.svg';
      case SailSVGAsset.heart:
        return 'assets/svgs/heart.svg';
      case SailSVGAsset.trendingUp:
        return 'assets/svgs/trending-up.svg';

      case SailSVGAsset.tabPeg:
        return 'assets/svgs/icon_tab_peg.svg';
      case SailSVGAsset.tabBMM:
        return 'assets/svgs/icon_tab_bmm.svg';
      case SailSVGAsset.tabWithdrawalExplorer:
        return 'assets/svgs/icon_tab_withdrawal_explorer.svg';

      case SailSVGAsset.tabSidechainSend:
        return 'assets/svgs/icon_tab_send.svg';

      case SailSVGAsset.tabZSideMeltCast:
        return 'assets/svgs/icon_tab_melt_cast.svg';
      case SailSVGAsset.tabZSideShieldDeshield:
        return 'assets/svgs/icon_tab_shield_deshield.svg';
      case SailSVGAsset.tabZSideOperationStatuses:
        return 'assets/svgs/icon_tab_operation_statuses.svg';

      case SailSVGAsset.tabConsole:
        return 'assets/svgs/icon_tab_console.svg';
      case SailSVGAsset.tabSettings:
        return 'assets/svgs/icon_tab_settings.svg';
      case SailSVGAsset.tabTools:
        return 'assets/svgs/icon_tab_tools.svg';
      case SailSVGAsset.tabStarters:
        return 'assets/svgs/icon_tab_starters.svg';

      case SailSVGAsset.layerTwoLabsLogo:
        return 'assets/svgs/layertwolabs.svg';

      case SailSVGAsset.iconCalendar:
        return 'assets/svgs/icon_calendar.svg';
      case SailSVGAsset.iconQuestion:
        return 'assets/svgs/icon_question.svg';
      case SailSVGAsset.iconSearch:
        return 'assets/svgs/icon_search.svg';
      case SailSVGAsset.iconCopy:
        return 'assets/svgs/icon_copy.svg';
      case SailSVGAsset.iconRestart:
        return 'assets/svgs/icon_restart.svg';
      case SailSVGAsset.iconArrow:
        return 'assets/svgs/icon_arrow_down.svg';
      case SailSVGAsset.iconArrowForward:
        return 'assets/svgs/icon_arrow_forward.svg';
      case SailSVGAsset.iconClose:
        return 'assets/svgs/icon_close.svg';
      case SailSVGAsset.iconGlobe:
        return 'assets/svgs/icon_globe.svg';
      case SailSVGAsset.iconExpand:
        return 'assets/svgs/icon_expand.svg';
      case SailSVGAsset.iconDropdown:
        return 'assets/svgs/icon_dropdown.svg';
      case SailSVGAsset.iconDeposit:
        return 'assets/svgs/icon_deposit.svg';
      case SailSVGAsset.iconWithdraw:
        return 'assets/svgs/icon_withdraw.svg';

      case SailSVGAsset.iconFormat:
        return 'assets/svgs/icon_format.svg';
      case SailSVGAsset.iconMelt:
        return 'assets/svgs/icon_melt.svg';
      case SailSVGAsset.iconCast:
        return 'assets/svgs/icon_cast.svg';
      case SailSVGAsset.iconTerminal:
        return 'assets/svgs/icon_terminal.svg';
      case SailSVGAsset.iconNetwork:
        return 'assets/svgs/icon_network.svg';
      case SailSVGAsset.iconPeers:
        return 'assets/svgs/icon_peers.svg';
      case SailSVGAsset.iconPen:
        return 'assets/svgs/icon_pen.svg';
      case SailSVGAsset.iconCheck:
        return 'assets/svgs/icon_check.svg';
      case SailSVGAsset.iconNewWindow:
        return 'assets/svgs/icon_new_window.svg';
      case SailSVGAsset.iconTools:
        return 'assets/svgs/icon_tools.svg';

      case SailSVGAsset.iconHome:
        return 'assets/svgs/icon_home.svg';
      case SailSVGAsset.iconSend:
        return 'assets/svgs/icon_send.svg';
      case SailSVGAsset.iconReceive:
        return 'assets/svgs/icon_receive.svg';
      case SailSVGAsset.iconTransactions:
        return 'assets/svgs/icon_transactions.svg';
      case SailSVGAsset.iconSidechains:
        return 'assets/svgs/icon_sidechains.svg';
      case SailSVGAsset.iconLearn:
        return 'assets/svgs/icon_learn.svg';

      case SailSVGAsset.iconSuccess:
        return 'assets/svgs/icon_success.svg';
      case SailSVGAsset.iconPending:
        return 'assets/svgs/icon_pending.svg';
      case SailSVGAsset.iconPendingHalf:
        return 'assets/svgs/icon_pending_half.svg';
      case SailSVGAsset.iconFailed:
        return 'assets/svgs/icon_failed.svg';
      case SailSVGAsset.iconInfo:
        return 'assets/svgs/icon_info.svg';
      case SailSVGAsset.iconSelected:
        return 'assets/svgs/icon_selected.svg';
      case SailSVGAsset.iconCoins:
        return 'assets/svgs/icon_coins.svg';
      case SailSVGAsset.iconConnectionStatus:
        return 'assets/svgs/icon_connection_status.svg';
      case SailSVGAsset.iconWarning:
        return 'assets/svgs/icon_warning.svg';
      case SailSVGAsset.iconWallet:
        return 'assets/svgs/icon_wallet.svg';
      case SailSVGAsset.iconCoinnews:
        return 'assets/svgs/icon_coinnews.svg';
      case SailSVGAsset.iconDelete:
        return 'assets/svgs/icon_delete.svg';
      case SailSVGAsset.iconMultisig:
        return 'assets/svgs/icon_multisig.svg';
      case SailSVGAsset.iconBitdrive:
        return 'assets/svgs/icon_bitdrive.svg';
      case SailSVGAsset.iconHDWallet:
        return 'assets/svgs/icon_hdwallet.svg';

      case SailSVGAsset.lightMode:
        return 'assets/svgs/icon_light_mode.svg';
      case SailSVGAsset.darkMode:
        return 'assets/svgs/icon_dark_mode.svg';
      case SailSVGAsset.lightDarkMode:
        return 'assets/svgs/icon_light_dark_mode.svg';

      case SailSVGAsset.meltCastDiagram:
        return 'assets/pngs/meltcastdiagram.png';

      case SailSVGAsset.dividerDot:
        return 'assets/svgs/divider_dot.svg';
    }
  }
}

extension PNGAsAssetPath on SailPNGAsset {
  String toAssetPath() {
    switch (this) {
      case SailPNGAsset.meltCastDiagram:
        return 'assets/pngs/meltcastdiagram.png';
      case SailPNGAsset.articleBeginner:
        return 'assets/pngs/article-beginner.png';
    }
  }
}
